#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# Docker serves DNS on 127.0.0.11 but podman/CI runtimes list their own server.
if [ "${O9S_NGINX_RESOLVER:-127.0.0.11}" = "127.0.0.11" ]; then
  _resolv_ns="$(awk '$1 == "nameserver" { print $2 }' /etc/resolv.conf 2>/dev/null | paste -sd " " -)"
  [ -n "${_resolv_ns}" ] && export O9S_NGINX_RESOLVER="${_resolv_ns}"
fi
b19-log info "NGINX" "resolver is ${O9S_NGINX_RESOLVER:-unset}"
