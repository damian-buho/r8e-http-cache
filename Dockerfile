# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

ARG O9S_NGINX_BASE_IMAGE=registry.invalid/o9s/nginx:latest
# .invalid zone used to force you to set the real registry

FROM ${O9S_NGINX_BASE_IMAGE} AS r8e-http-cache

ARG M6E_BUILD_DEBUG=""
ARG M6E_VERSION
ARG M6E_NEAR_CACHE_HOST=""
ARG M6E_AI=N
ARG M6E_APT_CACHE_HOST=""
ARG M6E_APT_CACHE_PORT=""
ARG M6E_NAMESPACE
ARG M6E_PROJECT
ARG LANG=""
ARG B19_VERBOSITY
ARG TARGETARCH

ENV O9S_NGINX_INDEX_TYPE=cache                      \
    O9S_NGINX_ACCESS_LOG="/dev/stdout cache"        \
    O9S_NGINX_INCLUDE_OPTIONAL=enable-status        \
    O9S_NGINX_PROXY_BUFFERS_NUM=32                  \
    O9S_NGINX_PROXY_BUFFERS_SIZE=64k                \
    O9S_NGINX_PROXY_BUFFER_SIZE=16k                 \
    O9S_NGINX_PROXY_CACHE_BACKGROUND_UPDATE=on      \
    O9S_NGINX_PROXY_CACHE_INACTIVE=90d              \
    O9S_NGINX_PROXY_CACHE_KEYS_SIZE=256m            \
    O9S_NGINX_PROXY_CACHE_LOCK=on                   \
    O9S_NGINX_PROXY_CACHE_LOCK_TIMEOUT=300s         \
    O9S_NGINX_PROXY_CACHE_MAX_SIZE=" max_size=20G"  \
    O9S_NGINX_PROXY_CACHE_REVALIDATE=on             \
    O9S_NGINX_PROXY_CACHE_USE_STALE="updating error timeout http_500 http_502 http_503 http_504" \
    O9S_NGINX_PROXY_CACHE_VALID_200=90d             \
    O9S_NGINX_PROXY_CACHE_VALID_301=90d             \
    O9S_NGINX_PROXY_CACHE_VALID_ANY=1m              \
    O9S_NGINX_PROXY_FORCE_RANGES=on                 \
    O9S_NGINX_PROXY_IGNORE_CLIENT_ABORT=on          \
    O9S_NGINX_PROXY_INTERCEPT_ERRORS=on             \
    O9S_NGINX_PROXY_MAX_TEMP_FILE_SIZE=1024m        \
    O9S_NGINX_PROXY_SSL_SERVER_NAME=on              \
    O9S_NGINX_RECURSIVE_ERROR_PAGES=on

# Empty allowlist regex means default deny; widen only for local dev.
ENV R8E_HTTP_CACHE_ALLOWLIST_REGEX=

USER 0

WORKDIR ${B19_HOME}

COPY --chown=${B19_UID}:${B19_GID} .container/root/ /

RUN --mount=type=bind,from=fetch,source=.,target=/fetch                                           \
    --mount=type=cache,target=${B19_DOWNLOAD_PATH},sharing=shared                                 \
    --mount=type=cache,id=apt-cache-${B19_UBUNTU_SERIES}-${TARGETARCH},target=/var/cache/apt,sharing=shared     \
    --mount=type=cache,id=apt-lists-${B19_UBUNTU_SERIES}-${TARGETARCH},target=/var/lib/apt,sharing=shared       \
    --mount=type=tmpfs,target=${B19_TEMP_PATH}                                                    \
    build-stage root                                                                              \
    && mkdir -p "${O9S_NGINX_CACHE_PATH}/proxy"                                                   \
    && chown "${B19_UID}:${B19_GID}" "${O9S_NGINX_CACHE_PATH}" "${O9S_NGINX_CACHE_PATH}/proxy"

# hadolint ignore=DL3066 # B19_UID comes from the root
USER ${B19_UID}

COPY --chown=${B19_UID}:${B19_GID} .container/user/ /

RUN --mount=type=bind,from=fetch,source=.,target=/fetch                                             \
    --mount=type=cache,target=${B19_DOWNLOAD_PATH},sharing=shared,uid=${B19_UID},gid=${B19_GID}     \
    --mount=type=tmpfs,target=${B19_TEMP_PATH}                                                      \
    build-stage user

# This image serves stale from cache during an outage, so lost outside reads as healthy.
ENV B19_HEALTH_EGRESS=false

# ENTRYPOINT ["entrypoint.d"] is inherited
# HEALTHCHECK CMD ["healthcheck.d"] is inherited

# Enable Traefik Docker Discovery
LABEL traefik.enable=true
LABEL traefik.http.routers.r8e-http-cache.rule="Host(`http-cache.docker.localhost`)"
LABEL traefik.http.routers.r8e-http-cache.entrypoints=web,websecure
LABEL traefik.http.routers.r8e-http-cache.middlewares=redirect-to-https@file
LABEL traefik.http.services.r8e-http-cache.loadbalancer.server.port=${O9S_NGINX_HTTP_PORT}
