#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# shellcheck disable=SC2016 # $vars below are literal nginx patterns, never expansions

  set -eou pipefail

  _cfg="$(mktemp)"
  trap 'rm -f "${_cfg}"' EXIT
  show-config > "${_cfg}"

  _fail=0
  present() {
    if grep -qF "$1" "${_cfg}"; then
      printf 'cache-render: present: %s\n' "$1"
    else
      printf 'cache-render: MISSING: %s\n' "$1"
      _fail=1
    fi
  }
  match() {
    if grep -qE "$1" "${_cfg}"; then
      printf 'cache-render: present: %s\n' "$1"
    else
      printf 'cache-render: MISSING: %s\n' "$1"
      _fail=1
    fi
  }
  absent() {
    if grep -vE '^[[:space:]]*#' "${_cfg}" | grep -qF "$1"; then
      printf 'cache-render: UNEXPECTED: %s\n' "$1"
      _fail=1
    else
      printf 'cache-render: absent: %s\n' "$1"
    fi
  }

  # Slice wiring keeps range clients on shared entries.
  match 'proxy_cache_key\s+"\$scheme\$upstream_host\$upstream_port\$upstream_path\$cache_qs\$slice_range"'
  match '^[[:space:]]*slice +[^[:space:];]+;'
  present 'proxy_cache_valid 206'
  present 'proxy_set_header Range $slice_range;'
  # Plus-only purge must never sneak into this open-source build.
  absent 'proxy_cache_purge'
  # Method guard stands in both cache locations.
  if [ "$(grep -c 'limit_except GET HEAD' "${_cfg}")" -ge 2 ]; then
    printf 'cache-render: present: limit_except x2\n'
  else
    printf 'cache-render: MISSING: limit_except x2\n'
    _fail=1
  fi
  # Policy maps and their gates.
  present 'map $check_host $upstream_allowed'
  present 'map $check_host $upstream_blocked'
  present 'map $args $cache_qs'
  present 'if ($upstream_allowed = 0)'
  present 'if ($upstream_blocked = 1)'
  # Redirect chain follows hops internally with a loop cap.
  present 'error_page 301 302 303 307 308 = @redirect'
  present 'location @redirect'
  present 'return 508'
  present 'location = /'
  # Correct upstream identity per fetch.
  present 'proxy_set_header Host $upstream_host$upstream_port'
  present 'proxy_ssl_name $upstream_host'
  # Stale survives outages; wrong-host variables stay dead.
  present 'proxy_cache_use_stale'
  present 'updating error timeout http_500 http_502 http_503 http_504'
  absent '$proxy_host'
  # Observability surface.
  present 'location /status/nginx'
  present 'log_format cache'
  present '/dev/stdout cache'
  present 'cache=$upstream_cache_status host=$upstream_host target=$target'

  exit "${_fail}"
