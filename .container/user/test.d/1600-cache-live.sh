#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Single run per container: fixed upstream ports and the persistent cache fail repeats.

  set -eou pipefail

  _port="${O9S_NGINX_HTTP_PORT:-8080}"
  _self="r8e-http-cache"
  _up_http=18080
  _up_tls=18443
  # Cache upstreams are https-only, so positives fetch the TLS port below.
  _fail=0

  check() {
    if [ "$1" = "$2" ]; then
      printf 'cache-live: ok: %s\n' "$3"
    else
      printf 'cache-live: FAIL: %s (want %s, got %s)\n' "$3" "$2" "$1"
      _fail=1
    fi
  }
  code_of() {
    curl --silent --output /dev/null --write-out '%{http_code}' --max-time 20 "$1" || true
  }

  # Refusals hold under every allowlist, so they always run.
  check "$(code_of "http://127.0.0.1:${_port}/")" "400" "bare / is 400"
  check "$(code_of "http://127.0.0.1:${_port}/user@host/x")" "400" "userinfo host is 400"
  check "$(code_of "http://127.0.0.1:${_port}/host./x")" "400" "trailing-dot host is 400"
  check "$(code_of "http://127.0.0.1:${_port}/host:abc/x")" "400" "bad port is 400"
  check "$(code_of "http://127.0.0.1:${_port}/127.0.0.1:${_up_http}/x")" "403" "loopback is 403"
  check "$(curl --silent --output /dev/null --write-out '%{http_code}' --max-time 20 --request POST "http://127.0.0.1:${_port}/${_self}:${_up_http}/file" || true)" "403" "POST is refused"

  # Positives need the allowlist to admit the throwaway upstream.
  if [ "$(code_of "http://127.0.0.1:${_port}/${_self}:${_up_tls}/probe")" = "403" ]; then
    printf 'cache-live: allowlist denies %s, skipping positive fetches\n' "${_self}"
    exit "${_fail}"
  fi
  _tmp="$(mktemp -d)"
  trap 'nginx -c "${_tmp}/upstream.conf" -s stop 2>/dev/null || true; rm -rf "${_tmp}"' EXIT
  _crt="${_tmp}/upstream.crt"
  _key="${_tmp}/upstream.key"
  # Mint a per-run self-signed cert; the EXIT trap removes it with ${_tmp}.
  openssl req -x509 -newkey rsa:2048 -nodes -days 2 -subj "/CN=${_self}" -addext "subjectAltName=DNS:${_self}" -keyout "${_key}" -out "${_crt}" 2>/dev/null
  cat > "${_tmp}/upstream.conf" <<EOF
worker_processes 1;
pid ${_tmp}/upstream.pid;
error_log ${_tmp}/upstream-error.log warn;
events { worker_connections 16; }
http {
    log_format test_host '\$http_host \$request';
    access_log ${_tmp}/upstream-access.log test_host;
    server {
        listen ${_up_http};
        listen ${_up_tls} ssl;
        ssl_certificate ${_crt};
        ssl_certificate_key ${_key};
        server_name ${_self};
        location = /file { return 200 'test-body'; }
        location = /redir { return 301 'https://${_self}:${_up_tls}/final'; }
        location = /redir-q { return 301 'https://${_self}:${_up_tls}/final?from=redir-q'; }
        location = /final { return 200 'final-body'; }
    }
}
EOF
  nginx -c "${_tmp}/upstream.conf"
  for _i in 1 2 3 4 5; do
    if curl --silent --insecure --output /dev/null --fail "https://127.0.0.1:${_up_tls}/file" 2>/dev/null; then
      break
    fi
    sleep 1
  done

  _hdrs="${_tmp}/headers.txt"
  fetch() {
    curl --silent --dump-header "${_hdrs}" --output "$2" --write-out '%{http_code}' --max-time 20 "$1" || true
  }
  status_of() {
    grep -i '^x-cache-status:' "${_hdrs}" | tr -d '\r' | awk '{print $2}' || true
  }

  # Second fetch of the same URL is a HIT with identical bytes.
  check "$(fetch "http://127.0.0.1:${_port}/${_self}:${_up_tls}/file" "${_tmp}/first")" "200" "first fetch is 200"
  check "$(status_of)" "MISS" "first fetch is MISS"
  check "$(fetch "http://127.0.0.1:${_port}/${_self}:${_up_tls}/file" "${_tmp}/second")" "200" "second fetch is 200"
  check "$(status_of)" "HIT" "second fetch is HIT"
  check "$(cat "${_tmp}/second")" "test-body" "HIT body matches"
  check "$(grep -cF "${_self}:${_up_tls} GET /file " "${_tmp}/upstream-access.log" || true)" "1" "upstream saw one fetch with correct Host"

  # Absolute redirect targets resolve through the same fetch path.
  check "$(fetch "http://127.0.0.1:${_port}/${_self}:${_up_tls}/redir" "${_tmp}/redir")" "200" "redirect lands on 200"
  check "$(cat "${_tmp}/redir")" "final-body" "redirect serves final body"
  if grep -qi '^x-upstream-redirect:' "${_hdrs}"; then
    printf 'cache-live: ok: redirect header present\n'
  else
    printf 'cache-live: FAIL: redirect header missing\n'
    _fail=1
  fi

  # Target query strings survive the hop; the original args never leak in.
  check "$(fetch "http://127.0.0.1:${_port}/${_self}:${_up_tls}/redir-q" "${_tmp}/redir_q")" "200" "query redirect lands on 200"
  check "$(cat "${_tmp}/redir_q")" "final-body" "query redirect serves final body"
  check "$(grep -cF "GET /final?from=redir-q " "${_tmp}/upstream-access.log" || true)" "1" "upstream saw redirect query"

  # A warm entry keeps serving after the origin dies.
  nginx -c "${_tmp}/upstream.conf" -s stop
  sleep 1
  check "$(fetch "http://127.0.0.1:${_port}/${_self}:${_up_tls}/file" "${_tmp}/down")" "200" "warm entry serves while upstream is down"
  check "$(cat "${_tmp}/down")" "test-body" "down body matches"

  exit "${_fail}"
