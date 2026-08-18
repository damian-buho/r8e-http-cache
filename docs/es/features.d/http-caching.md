<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Proxy de caché HTTP genérico

- Imagen delgada sobre `o9s/nginx` (base entre espacios de nombres); el runtime de nginx, los módulos, HTTP/3, la precompresión y la configuración por entorno se heredan de la base — esta imagen solo añade el enrutado y el ajuste de la caché
- Escucha en el puerto de nginx `${O9S_NGINX_HTTP_PORT}` — predeterminado `80`
- Esquema de URL `/{host}/{path}`: el primer segmento de la ruta se extrae como host upstream, el resto se proxy por HTTPS hacia `https://{host}{path}` (`.container/user/app/.config/includes/index/cache.nginx.j2`)
- Falta el primer segmento → `400`; las redirecciones (301/302/303/307/308) se siguen internamente mediante una location `@redirect` en lugar de pasarse al cliente
- Cabeceras de respuesta añadidas `always`: `X-Cache-Status` (`$upstream_cache_status`), `X-Upstream-Host`, `X-Upstream-Target`, `X-Upstream-Redirect`
- Zona de caché `proxy-cache`, clave de caché `$scheme$proxy_host$request_uri`; seleccionada con `O9S_NGINX_INDEX_TYPE=cache`
- Traefik habilitado: router `r8e-http-cache` en `` Host(`http-cache.docker.localhost`) ``, entrypoints `web,websecure`, middleware `redirect-to-https@file`, puerto del balanceador `${O9S_NGINX_HTTP_PORT}`
- Valores de ajuste de caché definidos por esta imagen (consumidos por la configuración por entorno heredada de o9s/nginx):
    - `O9S_NGINX_PROXY_CACHE_VALID_200=90d`, `O9S_NGINX_PROXY_CACHE_VALID_301=90d`, `O9S_NGINX_PROXY_CACHE_VALID_ANY=1m`
    - `O9S_NGINX_PROXY_CACHE_INACTIVE=90d`, `O9S_NGINX_PROXY_CACHE_KEYS_SIZE=8m`
    - `O9S_NGINX_PROXY_CACHE_LOCK=on`, `O9S_NGINX_PROXY_CACHE_LOCK_TIMEOUT=300s`
    - `O9S_NGINX_PROXY_CACHE_REVALIDATE=on`, `O9S_NGINX_PROXY_CACHE_USE_STALE=updating`, `O9S_NGINX_PROXY_CACHE_BACKGROUND_UPDATE=on`
    - `O9S_NGINX_PROXY_BUFFERS_NUM=32`, `O9S_NGINX_PROXY_BUFFERS_SIZE=64k`, `O9S_NGINX_PROXY_BUFFER_SIZE=16k`, `O9S_NGINX_PROXY_MAX_TEMP_FILE_SIZE=1024m`
    - `O9S_NGINX_PROXY_FORCE_RANGES=on`, `O9S_NGINX_PROXY_IGNORE_CLIENT_ABORT=on`, `O9S_NGINX_PROXY_INTERCEPT_ERRORS=on`, `O9S_NGINX_PROXY_SSL_SERVER_NAME=on`, `O9S_NGINX_RECURSIVE_ERROR_PAGES=on`

<!-- textlint-enable -->
