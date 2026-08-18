<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Універсальний кешуючий HTTP-проксі

- Тонкий образ на `o9s/nginx` (міжпросторова база); nginx-рантайм, модулі, HTTP/3, передстиснення й конфігурація з середовища успадковані від бази — цей образ лише додає маршрутизацію кешу й тюнінг
- Слухає на порту nginx `${O9S_NGINX_HTTP_PORT}` — типово `80`
- Схема URL `/{host}/{path}`: перший сегмент шляху витягується як upstream-хост, решта проксується по HTTPS до `https://{host}{path}` (`.container/user/app/.config/includes/index/cache.nginx.j2`)
- Немає першого сегмента → `400`; редиректи (301/302/303/307/308) відслідковуються внутрішньо через location `@redirect`, а не віддаються клієнту
- Заголовки відповіді, що додаються `always`: `X-Cache-Status` (`$upstream_cache_status`), `X-Upstream-Host`, `X-Upstream-Target`, `X-Upstream-Redirect`
- Зона кешу `proxy-cache`, ключ кешу `$scheme$proxy_host$request_uri`; вибирається змінною `O9S_NGINX_INDEX_TYPE=cache`
- Traefik увімкнено: роутер `r8e-http-cache` на `` Host(`http-cache.docker.localhost`) ``, entrypoints `web,websecure`, middleware `redirect-to-https@file`, порт балансувальника `${O9S_NGINX_HTTP_PORT}`
- Типові значення тюнінгу кешу, задані цим образом (споживаються успадкованою конфігурацією o9s/nginx):
    - `O9S_NGINX_PROXY_CACHE_VALID_200=90d`, `O9S_NGINX_PROXY_CACHE_VALID_301=90d`, `O9S_NGINX_PROXY_CACHE_VALID_ANY=1m`
    - `O9S_NGINX_PROXY_CACHE_INACTIVE=90d`, `O9S_NGINX_PROXY_CACHE_KEYS_SIZE=8m`
    - `O9S_NGINX_PROXY_CACHE_LOCK=on`, `O9S_NGINX_PROXY_CACHE_LOCK_TIMEOUT=300s`
    - `O9S_NGINX_PROXY_CACHE_REVALIDATE=on`, `O9S_NGINX_PROXY_CACHE_USE_STALE=updating`, `O9S_NGINX_PROXY_CACHE_BACKGROUND_UPDATE=on`
    - `O9S_NGINX_PROXY_BUFFERS_NUM=32`, `O9S_NGINX_PROXY_BUFFERS_SIZE=64k`, `O9S_NGINX_PROXY_BUFFER_SIZE=16k`, `O9S_NGINX_PROXY_MAX_TEMP_FILE_SIZE=1024m`
    - `O9S_NGINX_PROXY_FORCE_RANGES=on`, `O9S_NGINX_PROXY_IGNORE_CLIENT_ABORT=on`, `O9S_NGINX_PROXY_INTERCEPT_ERRORS=on`, `O9S_NGINX_PROXY_SSL_SERVER_NAME=on`, `O9S_NGINX_RECURSIVE_ERROR_PAGES=on`

<!-- textlint-enable -->
