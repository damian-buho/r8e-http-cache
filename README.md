<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
pf-cli-managed: yes
-->

[Español](docs/es/README.md) · [Українська](docs/uk/README.md)

# R8E / HTTP Cache

Community-maintained distribution of Nginx built on B19/Ubuntu. This repository holds only the packaging — Dockerfile, build scripts, and configuration, all MIT-licensed; the upstream Nginx is fetched at build time and retains its own licensing.

[![Stand with Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://damian-buho.github.io/support-ukraine/) [![Projectfile inside](https://badges.kiota.ch/static/v1?label=projectfile&message=inside&labelColor=0d0d0d&color=8c6723&style=flat-square)](https://projectfile.org) [![License](https://badges.kiota.ch/static/v1?label=license&message=MIT&color=1e5913&style=flat-square)](LICENSE) [![PRs welcome](https://badges.kiota.ch/static/v1?label=PRs&message=welcome&color=1e5913&style=flat-square)](CONTRIBUTING.md) [![REUSE compliance](https://api.reuse.software/badge/github.com/damian-buho/r8e-http-cache)](https://api.reuse.software/info/github.com/damian-buho/r8e-http-cache)

![Project status](https://badges.kiota.ch/static/v1?label=status&message=maintained&color=1d63ed&style=flat-square) [![Last commit on GitHub](https://badges.kiota.ch/github/last-commit/damian-buho/r8e-http-cache?label=last%20commit%20on%20GitHub&style=flat-square)](https://github.com/damian-buho/r8e-http-cache) [![Last commit on kiota.ch](https://badges.kiota.ch/gitea/last-commit/r8e/http-cache?gitea_url=https://kiota.ch&label=last%20commit%20on%20kiota.ch&style=flat-square)](https://kiota.ch/r8e/http-cache)

[![Publish pipeline on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/published.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Vulnerability audit on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/audited.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Dependency freshness on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Analysis sweep on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/analyzed.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions)

[![Publish pipeline on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/published.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Vulnerability audit on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/audited.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Dependency freshness on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Analysis sweep on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/analyzed.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions)

## Features

- Built for large CI artifacts
- Generic HTTP caching proxy
- Serves through upstream outages
- Safe shared caching

It also inherits the features of B19 / Ubuntu — see [Features](docs/FEATURES.md) for the full list.

## Quick Start

Save this as `compose.yaml`:

```yaml
---
services:
  http-cache:
    image: docker.io/damianbuho/r8e-http-cache:latest
    ports:
      - "8080:8080"
    volumes:
      - http-cache:/app/cache
    cap_drop: [ALL]
    security_opt: [no-new-privileges:true]
    restart: unless-stopped
volumes:
  http-cache:
```

Then start it with `docker compose up --detach`.

## What this provides

- **Service** `http-cache` — listens on `8080 (http)` — Caching HTTP proxy
- **Container image** `ghcr.io/damian-buho/r8e/http-cache:latest`
- **Container image** `damianbuho/r8e-http-cache:latest`

## Installation

Pull the published container image:

### Pull from GHCR — linux/amd64, linux/arm64

```sh
docker pull ghcr.io/damian-buho/r8e/http-cache:latest
```

### Pull from DockerHub — linux/amd64

```sh
docker pull damianbuho/r8e-http-cache:latest
```

Stable releases also publish `X.Y.Z`, `X.Y` and `X` tags — pull the precision you want to pin.

If the registries above are unreachable, pull from the origin instead:

### Pull from Kiota — linux/amd64

```sh
docker pull kiota.ch/r8e/http-cache:latest
```

## Usage

Run the service in the background, publishing its ports:

### From GHCR

```sh
docker run --detach --publish 8080:8080/tcp ghcr.io/damian-buho/r8e/http-cache:latest
```

### From DockerHub

```sh
docker run --detach --publish 8080:8080/tcp damianbuho/r8e-http-cache:latest
```

## Building

Clone the repository with its submodules:

```sh
git clone --recurse-submodules https://github.com/damian-buho/r8e-http-cache http-cache && cd http-cache
```

Build the container image locally:

```sh
make container-build
```

- [Makefile reference](docs/how-to/MAKEFILE.md)

Run `make` with no arguments for the default target; run `make help` to list every target.

For the local dev loop, `make dev-container` brings up the dev-container.

Pipeline entry points:

- `make analyzed` — Run the heavy analysis sweep (mutation testing, benchmarks)
- `make audited` — Re-scan the pinned dependencies and published artifacts for new vulnerabilities
- `make check-outdated` — Report every pinned dependency that lags upstream
- `make ready-to-publish` — Run the pseudo-CI pipeline locally — build, test and scan, without publishing

## Policies

- [How to contribute](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Getting support](SUPPORT.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [AI and LLM Policy](AI_POLICY.md)

## Links

- [Projectfile Specification](https://projectfile.org)

## License

This project is licensed under MIT — see the [LICENSE](LICENSE) file for details.
