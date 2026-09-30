<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
pf-cli-managed: yes
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../README.md) · [Українська](../uk/README.md)

# R8E / HTTP Cache

Distribución de Nginx mantenida por la comunidad, construida sobre B19/Ubuntu. Este repositorio contiene únicamente el empaquetado — Dockerfile, scripts de compilación y configuración, todo con licencia MIT; el código original de Nginx se obtiene en tiempo de compilación y conserva su propia licencia.

[![Stand with Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://damian-buho.github.io/support-ukraine/) [![Projectfile inside](https://badges.kiota.ch/static/v1?label=projectfile&message=inside&labelColor=0d0d0d&color=8c6723&style=flat-square)](https://projectfile.org) [![License](https://badges.kiota.ch/static/v1?label=license&message=MIT&color=1e5913&style=flat-square)](LICENSE) [![Commit style](https://badges.kiota.ch/static/v1?label=commits&message=conventional%20v1.0.0&color=1877aa&style=flat-square)](https://www.conventionalcommits.org/es/v1.0.0/) ![Workflow](https://badges.kiota.ch/static/v1?label=workflow&message=git-flow&color=1877aa&style=flat-square) [![Versioning](https://badges.kiota.ch/static/v1?label=versioning&message=semantic%20v2.0.0&color=1877aa&style=flat-square)](https://semver.org/lang/es/) [![PRs welcome](https://badges.kiota.ch/static/v1?label=PRs&message=welcome&color=1e5913&style=flat-square)](CONTRIBUTING.md) [![Citation](https://badges.kiota.ch/static/v1?label=citation&message=cff&color=1877aa&style=flat-square)](CITATION.cff) [![REUSE compliance](https://api.reuse.software/badge/github.com/damian-buho/r8e-http-cache)](https://api.reuse.software/info/github.com/damian-buho/r8e-http-cache)

![Project status](https://badges.kiota.ch/static/v1?label=status&message=maintained&color=1d63ed&style=flat-square) [![Last commit on GitHub](https://badges.kiota.ch/github/last-commit/damian-buho/r8e-http-cache?label=last%20commit%20on%20GitHub&style=flat-square)](https://github.com/damian-buho/r8e-http-cache) [![Last commit on kiota.ch](https://badges.kiota.ch/gitea/last-commit/r8e/http-cache?gitea_url=https://kiota.ch&label=last%20commit%20on%20kiota.ch&style=flat-square)](https://kiota.ch/r8e/http-cache)

[![Publish pipeline on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/published.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Vulnerability audit on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/audited.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Dependency freshness on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Analysis sweep on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/analyze.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions)

[![Publish pipeline on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/published.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Vulnerability audit on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/audited.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Dependency freshness on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Analysis sweep on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/analyze.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions)

## Características

- Pensada para artefactos grandes de CI
- Proxy de caché HTTP genérico
- Sirve aunque los orígenes caigan
- Caché compartida y segura

También hereda las características de Heredado de B19 / Ubuntu; consulta [FEATURES.md](FEATURES.md) para ver la lista completa.

## Qué entrega este proyecto

- **Imagen de contenedor** `ghcr.io/damian-buho/r8e/http-cache:latest`
- **Imagen de contenedor** `damianbuho/r8e-http-cache:latest`

## Instalación

Descarga la imagen de contenedor publicada:

### Descargar de GHCR — linux/amd64, linux/arm64

```sh
docker pull ghcr.io/damian-buho/r8e/http-cache:latest
```

### Descargar de DockerHub — linux/amd64

```sh
docker pull damianbuho/r8e-http-cache:latest
```

Las versiones estables también publican las etiquetas `X.Y.Z`, `X.Y` y `X`: descarga el nivel de precisión que quieras fijar.

Si los registros anteriores no están disponibles, descarga desde el origen:

### Descargar de Kiota — linux/amd64

```sh
docker pull kiota.ch/r8e/http-cache:latest
```

## Compilación

Clona el repositorio con sus submódulos:

```sh
git clone --recurse-submodules https://github.com/damian-buho/r8e-http-cache http-cache && cd http-cache
```

Construye la imagen de contenedor en local:

```sh
make container-build
```

- [Referencia del Makefile](../how-to/MAKEFILE.md)

Ejecuta `make` sin argumentos para el destino predeterminado; ejecuta `make help` para listar todos los destinos.

Para el bucle de desarrollo local, `make dev-container` levanta el dev-container.

Puntos de entrada de la canalización:

- `make analyze` — Ejecuta el análisis pesado (pruebas de mutación, benchmarks)
- `make audited` — Vuelve a escanear las dependencias fijadas y los artefactos publicados en busca de vulnerabilidades nuevas
- `make check-outdated` — Informa de cada dependencia fijada que va por detrás de su versión upstream
- `make ready-to-publish` — Ejecuta localmente el pipeline pseudo-CI — compila, prueba y escanea, sin publicar

## Políticas

- [Cómo contribuir](CONTRIBUTING.md)
- [Política de seguridad](SECURITY.md)
- [Cómo obtener ayuda](SUPPORT.md)
- [Código de conducta](CODE_OF_CONDUCT.md)
- [Política sobre IA y LLM](AI_POLICY.md)

## Enlaces

- [Especificación de Projectfile](https://projectfile.org)

## Licencia

Este proyecto se publica bajo la licencia MIT — consulta el archivo [LICENSE](LICENSE) para más detalles.

<!-- textlint-enable -->
