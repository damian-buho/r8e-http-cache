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

`/{host}/{path}` — the first path segment is used as the upstream host.

## Cache tuning ENV

- `O9S_NGINX_INDEX_TYPE=cache`
- `O9S_NGINX_PROXY_CACHE_VALID_200=90d`
- `O9S_NGINX_PROXY_CACHE_INACTIVE=90d`
- `O9S_NGINX_PROXY_CACHE_LOCK=on`, `_REVALIDATE=on`, `_USE_STALE=updating`

No secrets required. No Traefik labels.

## Upstream allowlist and SSRF protection

- Only `GET`/`HEAD` are relayed (`limit_except` in both cache locations); only those methods are cached.
- `map $upstream_host $upstream_allowed` (`includes/http/145-allowlist.nginx.j2`) is default deny. Widen via `R8E_HTTP_CACHE_ALLOWLIST_REGEX` (unanchored `~*` pattern, e.g. `^(registry\.example\.com|.*\.example\.org)$`). Local dev override: `R8E_HTTP_CACHE_ALLOWLIST_REGEX='.*'`.
- `map $upstream_host $upstream_blocked` in the same file rejects literal loopback, private, link-local, and cloud-metadata targets even when the allowlist is widened. A regex alone cannot stop DNS rebinding, so the allowlist stays the real gate: `proxy_pass` uses a variable, hence resolution happens per request through `O9S_NGINX_RESOLVER` (default Docker `127.0.0.11`, `ipv6=off`), and operators must keep interior names out of that resolver view and firewall egress accordingly.
- Host shape is validated before `proxy_pass`: empty, userinfo (`@`), and trailing-dot hosts get 400; blocked/denied hosts get 403.

## Stale-serving contract

- Warm entry plus dead upstream serves the stale body with `X-Cache-Status: STALE` (`proxy_cache_use_stale` covers `updating error timeout http_500 http_502 http_503 http_504`; `background_update on` revalidates in the background while `lock on` serializes thundering herds).
- Cold miss plus dead upstream has nothing to serve, so the upstream error (502/504) reaches the client. That is expected, not a bug.

## Documentation

- [Project objectives](@docs/goal.md)
- [Fitness criteria and acceptance](@docs/fit.md)
- [Completed features](@docs/done.md)
- [Known limitations](@docs/caveats.md)
- [Future plans](@docs/roadmap.md)
- [Available make targets](@docs/MAKEFILE.md)
