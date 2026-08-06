<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Generic HTTP caching proxy

- Thin image on `o9s/nginx` (cross-namespace base); nginx runtime, modules, HTTP/3, precompression and env-config are inherited from the base — this image only adds the cache routing and tuning
- Listens on nginx port `${O9S_NGINX_HTTP_PORT}` — default `80`
- URL scheme `/{host}/{path}`: the first path segment is extracted as the upstream host, the remainder is proxied over HTTPS to `https://{host}{path}` (`.container/user/app/.config/includes/index/cache.nginx.j2`)
- Missing first path segment → `400`; redirects (301/302/303/307/308) are followed internally via an `@redirect` location rather than passed to the client
- Response headers added `always`: `X-Cache-Status` (`$upstream_cache_status`), `X-Upstream-Host`, `X-Upstream-Target`, `X-Upstream-Redirect`
- Cache zone `proxy-cache`, cache key `$scheme$proxy_host$request_uri`; selected by `O9S_NGINX_INDEX_TYPE=cache`
- Traefik enabled: router `r8e-http-cache` on `` Host(`http-cache.docker.localhost`) ``, entrypoints `web,websecure`, `redirect-to-https@file` middleware, loadbalancer port `${O9S_NGINX_HTTP_PORT}`
- Cache tuning defaults set by this image (consumed by the inherited o9s/nginx env-config):
    - `O9S_NGINX_PROXY_CACHE_VALID_200=90d`, `O9S_NGINX_PROXY_CACHE_VALID_301=90d`, `O9S_NGINX_PROXY_CACHE_VALID_ANY=1m`
    - `O9S_NGINX_PROXY_CACHE_INACTIVE=90d`, `O9S_NGINX_PROXY_CACHE_KEYS_SIZE=8m`
    - `O9S_NGINX_PROXY_CACHE_LOCK=on`, `O9S_NGINX_PROXY_CACHE_LOCK_TIMEOUT=300s`
    - `O9S_NGINX_PROXY_CACHE_REVALIDATE=on`, `O9S_NGINX_PROXY_CACHE_USE_STALE=updating`, `O9S_NGINX_PROXY_CACHE_BACKGROUND_UPDATE=on`
    - `O9S_NGINX_PROXY_BUFFERS_NUM=32`, `O9S_NGINX_PROXY_BUFFERS_SIZE=64k`, `O9S_NGINX_PROXY_BUFFER_SIZE=16k`, `O9S_NGINX_PROXY_MAX_TEMP_FILE_SIZE=1024m`
    - `O9S_NGINX_PROXY_FORCE_RANGES=on`, `O9S_NGINX_PROXY_IGNORE_CLIENT_ABORT=on`, `O9S_NGINX_PROXY_INTERCEPT_ERRORS=on`, `O9S_NGINX_PROXY_SSL_SERVER_NAME=on`, `O9S_NGINX_RECURSIVE_ERROR_PAGES=on`
