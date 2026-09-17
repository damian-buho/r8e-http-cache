<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# r8e/http-cache

Docker image built on [o9s/nginx](../../o9s/nginx/AGENTS.md)

Nginx-based generic HTTP caching proxy.

## Key facts

- Base: `o9s/nginx` (single stage)
- Arch: amd64, arm64
- Traefik route `http-cache.docker.localhost` (labels in `Dockerfile`)

## URL format

`/{host}[:port]/{path}` — the first path segment is used as the upstream host. It is split off `$request_uri` (not `$uri`) so percent-encoding survives byte-identical, and path plus query forward as one part with no arg re-append.

- Upstreams are https only. Plain-http origins are out of scope: an http leg would let a MITM poison the cache, so there is no scheme selector. Non-https redirect targets are refused.
- A bare `/` returns 400 via `location = /`; unparsable shapes (bad ports, `//` prefixes) fall through to the same 400 inside `location /`.

## Redirects

- 301/302/303/307/308 are followed internally via a server-level `error_page`, so chains work across hops. Each hop appends a marker and the sixth returns 508, which terminates loops.
- Every redirect target clears the same policy as a direct fetch: https only, same allowlist, same interior/metadata block. Relative `/path` targets resolve against the original upstream; anything else unusable is a 502.
- Target splitting lives in `map` blocks (`includes/http/146-redirect.nginx`): `proxy_pass` with a variable reuses the original URI on `error_page` entry, so `@redirect` rewrites to the target path first and caches under its own key.

## Cache tuning ENV

- `O9S_NGINX_INDEX_TYPE=cache`
- `O9S_NGINX_PROXY_CACHE_VALID_200=90d`
- `O9S_NGINX_PROXY_CACHE_INACTIVE=90d`
- `O9S_NGINX_PROXY_CACHE_LOCK=on`, `_REVALIDATE=on`, full `_USE_STALE` error set (see contract below)

No secrets required.

## Upstream allowlist and SSRF protection

- Only `GET`/`HEAD` are relayed (`limit_except` in both cache locations); only those methods are cached.
- `map $check_host $upstream_allowed` (`includes/http/145-allowlist.nginx.j2`) is default deny, matched against the bare host without any port suffix. Widen via `R8E_HTTP_CACHE_ALLOWLIST_REGEX` (unanchored `~*` pattern, e.g. `^(registry\.example\.com|.*\.example\.org)$`). Local dev override: `R8E_HTTP_CACHE_ALLOWLIST_REGEX='.*'`.
- `map $check_host $upstream_blocked` in the same file rejects literal loopback, private, link-local, and cloud-metadata targets even when the allowlist is widened. A regular expression alone cannot stop DNS rebinding, so the allowlist stays the real gate: `proxy_pass` uses a variable, hence resolution happens per request through `O9S_NGINX_RESOLVER` (default Docker `127.0.0.11`, `ipv6=off`), and operators must keep interior names out of that resolver view and firewall egress accordingly.
- `entrypoint.d/0950-resolver.sh` adopts the nameservers from `/etc/resolv.conf` while `O9S_NGINX_RESOLVER` still carries the Docker default, so podman/CI runtimes resolve service names too; an explicit override is left alone.
- Host shape is validated before `proxy_pass`: empty, userinfo (`@`), and trailing-dot hosts get 400; blocked/denied hosts get 403.

## Stale-serving contract

- Warm entry plus dead upstream serves the stale body with `X-Cache-Status: STALE` (`proxy_cache_use_stale` covers `updating error timeout http_500 http_502 http_503 http_504`; `background_update on` revalidates in the background while `lock on` serializes thundering herds).
- Cold miss plus dead upstream has nothing to serve, so the upstream error (502/504) reaches the client. That is expected, not a bug.

## Persistent bounded cache

- Cache disk (`/app/cache`, 90d entries) lives on named volume `r8e-http-cache-data` (dev and pipeline); restarts keep entries, only `down -v` wipes them. The image seeds the dir owned by the runtime user so volume copy-up preserves ownership.
- Bounds: `max_size=20G` evicts LRU via the cache manager instead of filling the host disk; tune via `O9S_NGINX_PROXY_CACHE_MAX_SIZE`. Sizing math: ~8k keys per 1m of `keys_zone`, so 256m holds ~2M entries, and 2M npm/Go/PyPI artifacts at ~10KB average need ~20G. Raise zone and max_size together when entry counts outgrow that.
- `B19_HEALTH_EGRESS=false`: egress/DNS healthchecks stay off so an outside outage reads as healthy. The cache keeps serving stale (see contract above) instead of flapping unhealthy and restarting into a cold index.

## Observability

- Status endpoint `GET /status/nginx` (mandatory base server include `server/status.nginx`, never list `enable-status` under `O9S_NGINX_INCLUDE_OPTIONAL` — that file no longer exists) answers on localhost only (`allow 127.0.0.1; deny all`) and is also what the image healthcheck curls.
- Access log uses the `cache` format: the default fields plus `cache=$upstream_cache_status host=$upstream_host target=$target`. Hit ratio is `grep -o 'cache=[A-Z]*' access.log | sort | uniq -c` with values MISS/HIT/EXPIRED/STALE/UPDATING/BYPASS.
- `X-Cache-Status` / `X-Upstream-Host` / `X-Upstream-Target` are diagnostic-only. They are emitted from config at serve time, never stored in cache entries: on a HIT the location still runs and the headers describe the current request, so a HIT can never carry a previous MISS’s values.

## Invalidation, bypass, warm-up

- No network purge endpoint exists: `proxy_cache_purge` is Plus-only and not compiled into `o9s/nginx`. Purging needs container or volume access, which is the restriction. Per entry: `hex=$(printf '%s' '<scheme><host><request_uri>' | md5sum | cut -d' ' -f1)` with no separators (e.g. `httpsregistry.example.com/org/pkg-1.0.tgz`), then `find /app/cache/proxy -type f -name "$hex" -delete`. The next fetch MISSes and refills; the stale index entry ages out via the loader.
- `?nocache=1` (or `?comment=`) bypasses lookup and stores fresh, but under the bypassed URI, so it never heals the original entry. `Pragma: no-cache` or any `Authorization` header skips storing entirely: authenticated fetches always MISS and never poison the cache.
- `cache-warmup` prefetches `R8E_HTTP_CACHE_WARMUP_URLS` (space-separated full cache URLs) daily via Ofelia (`no-overlap`), empty by default so the job is a no-op until URLs are provided.
- Single global 90d TTL is deliberate: stock nginx cannot vary `proxy_cache_valid` per host, so per-host TTLs would need upstream `X-Accel-Expires` cooperation, which is out of scope.

## Large artifacts

- Slices (`R8E_HTTP_CACHE_SLICE`, default 1m) split large responses so concurrent range requests share slice entries; the cache key carries `$slice_range` and each fetch sends `Range $slice_range` upstream. Sliced 206 responses reuse the 90d TTL via an explicit 206 line (a server-level `proxy_cache_valid` replaces the inherited set, so the template repeats every code).
- Timeouts stay inherited (connect 30s, read 120s, send 30s): read fires on inter-byte gaps, not total time, so 120s already covers slow origins streaming multi-hundred-MB layers. All three remain ENV-tunable.
- Junk query args (`utm_*`, `fbclid`, `gclid`, `msclkid`, `mc_*`, `igshid`) collapse out of the cache key only when the whole query is junk; anything signature-bearing keeps the full original query in the key while the upstream still receives byte-identical args.
- Only `GET`/`HEAD` are cached (`proxy_cache_methods` inherited) and only those methods are relayed (method guard above).
- `proxy_max_temp_file_size` stays 1024m: with 1m slices steady-state temp use is small, and the cap only needs to fit the largest single response buffered for a slow client, comfortably inside the 20G volume.

## Documentation

- [HTTP caching proxy](docs/features.d/http-caching.md)
- [Available make targets](docs/MAKEFILE.md)

## Regression tests

- Run as `make dc-up-d container-test`: `container-test` alone reuses the running dev container, so a rebuild without `dc-up-d` tests the stale image.
- `test.d/1500-cache-render.sh` asserts the rendered config carries every fix: slice key, method guard, policy maps, redirect chain, status endpoint, cache log format.
- `test.d/1600-cache-live.sh` drives the running cache against a throwaway nginx upstream on the service name (`r8e-http-cache:18080` plain, `:18443` TLS with a per-run self-signed cert). Positives fetch the TLS port since cache upstreams are https-only, and run only where the allowlist admits that name (CI pipeline sets `^r8e-http-cache$`); under default deny they skip with a log line while the refusal assertions still run.
- Live STALE-status is not asserted: expiring an entry needs time travel, so the suite proves warm-serving-while-down plus the `use_stale` render assertion instead.
