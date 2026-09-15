<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# r8e/http-cache

Docker image built on [o9s/nginx](../../o9s/nginx/AGENTS.md)

Nginx-based generic HTTP caching proxy.

## Key facts

- Base: `o9s/nginx` (single stage)
- Arch: amd64 only

## URL format

`/{host}[:port]/{path}` — the first path segment is used as the upstream host. It is split off `$request_uri` (not `$uri`) so percent-encoding survives byte-identical, and path plus query forward as one part with no arg re-append.

- Upstreams are https only. Plain-http origins are out of scope: an http leg would let a MITM poison the cache, so there is no scheme selector. Non-https redirect targets are refused.
- A bare `/` returns 400 via `location = /`; unparsable shapes (bad ports, `//` prefixes) fall through to the same 400 inside `location /`.

## Redirects

- 301/302/303/307/308 are followed internally via a server-level `error_page`, so chains work across hops. Each hop appends a marker and the sixth returns 508, which terminates loops.
- Every redirect target clears the same policy as a direct fetch: https only, same allowlist, same interior/metadata block. Relative `/path` targets resolve against the original upstream; anything else unusable is a 502.

## Cache tuning ENV

- `O9S_NGINX_INDEX_TYPE=cache`
- `O9S_NGINX_PROXY_CACHE_VALID_200=90d`
- `O9S_NGINX_PROXY_CACHE_INACTIVE=90d`
- `O9S_NGINX_PROXY_CACHE_LOCK=on`, `_REVALIDATE=on`, `_USE_STALE=updating`

No secrets required. No Traefik labels.

## Upstream allowlist and SSRF protection

- Only `GET`/`HEAD` are relayed (`limit_except` in both cache locations); only those methods are cached.
- `map $check_host $upstream_allowed` (`includes/http/145-allowlist.nginx.j2`) is default deny, matched against the bare host without any port suffix. Widen via `R8E_HTTP_CACHE_ALLOWLIST_REGEX` (unanchored `~*` pattern, e.g. `^(registry\.example\.com|.*\.example\.org)$`). Local dev override: `R8E_HTTP_CACHE_ALLOWLIST_REGEX='.*'`.
- `map $upstream_host $upstream_blocked` in the same file rejects literal loopback, private, link-local, and cloud-metadata targets even when the allowlist is widened. A regex alone cannot stop DNS rebinding, so the allowlist stays the real gate: `proxy_pass` uses a variable, hence resolution happens per request through `O9S_NGINX_RESOLVER` (default Docker `127.0.0.11`, `ipv6=off`), and operators must keep interior names out of that resolver view and firewall egress accordingly.
- Host shape is validated before `proxy_pass`: empty, userinfo (`@`), and trailing-dot hosts get 400; blocked/denied hosts get 403.

## Stale-serving contract

- Warm entry plus dead upstream serves the stale body with `X-Cache-Status: STALE` (`proxy_cache_use_stale` covers `updating error timeout http_500 http_502 http_503 http_504`; `background_update on` revalidates in the background while `lock on` serializes thundering herds).
- Cold miss plus dead upstream has nothing to serve, so the upstream error (502/504) reaches the client. That is expected, not a bug.

## Persistent bounded cache

- Cache disk (`/app/cache`, 90d entries) lives on named volume `r8e-http-cache-data` (dev and pipeline); restarts keep entries, only `down -v` wipes them. The image seeds the dir owned by the runtime user so volume copy-up preserves ownership.
- Bounds: `max_size=20G` evicts LRU via the cache manager instead of filling the host disk; tune via `O9S_NGINX_PROXY_CACHE_MAX_SIZE`. Sizing math: ~8k keys per 1m of `keys_zone`, so 256m holds ~2M entries, and 2M npm/Go/PyPI artifacts at ~10KB average need ~20G. Raise zone and max_size together when entry counts outgrow that.
- `B19_HEALTH_EGRESS=false`: egress/DNS healthchecks stay off so an outside outage reads as healthy. The cache keeps serving stale (see contract above) instead of flapping unhealthy and restarting into a cold index.

## Documentation

- [Project objectives](@docs/goal.md)
- [Fitness criteria and acceptance](@docs/fit.md)
- [Completed features](@docs/done.md)
- [Known limitations](@docs/caveats.md)
- [Future plans](@docs/roadmap.md)
- [Available make targets](@docs/MAKEFILE.md)
