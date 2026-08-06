# SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
#
# SPDX-License-Identifier: MIT

# M6E MAKEFILE T3

# Rules

# Includes

# nginx base-image tag selector — inlined from the retired m6e/nginx module.
# Picks which o9s/nginx tag this image builds FROM (latest in prod, dev for
# maintainers) and forwards it into the build, as the module used to.
export O9S_NGINX_VERSION   ?= $(M6E_BASE_IMAGE_DEFAULT_VERSION)
M6E_DOCKER_BUILDX_OPTIONS  += --build-arg O9S_NGINX_VERSION

all: .makefile/core/initialize.mk

.makefile/core/initialize.mk:
	git submodule update --init --recursive
	$(MAKE) bootstrap

-include .makefile/core/initialize.mk
