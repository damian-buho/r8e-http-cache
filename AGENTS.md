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

## Documentation

- [Project objectives](@docs/goal.md)
- [Fitness criteria and acceptance](@docs/fit.md)
- [Completed features](@docs/done.md)
- [Known limitations](@docs/caveats.md)
- [Future plans](@docs/roadmap.md)
- [Available make targets](@docs/MAKEFILE.md)
