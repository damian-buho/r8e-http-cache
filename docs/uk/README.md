<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>
SPDX-License-Identifier: MIT
pf-cli-managed: yes
-->

<!-- textlint-disable terminology,common-misspellings -->

[English](../../README.md) · [Español](../es/README.md)

# R8E / HTTP Cache

Дистрибуція Nginx з підтримкою спільноти, зібрана на основі B19/Ubuntu. Цей репозиторій містить лише пакування — Dockerfile, скрипти збирання та конфігурацію, усе під ліцензією MIT; вихідний код Nginx отримують під час збирання, і він зберігає власну ліцензію.

[![Stand with Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://damian-buho.github.io/support-ukraine/) [![Projectfile inside](https://badges.kiota.ch/static/v1?label=projectfile&message=inside&labelColor=0d0d0d&color=8c6723&style=flat-square)](https://projectfile.org) [![License](https://badges.kiota.ch/static/v1?label=license&message=MIT&color=1e5913&style=flat-square)](LICENSE) [![PRs welcome](https://badges.kiota.ch/static/v1?label=PRs&message=welcome&color=1e5913&style=flat-square)](CONTRIBUTING.md) [![REUSE compliance](https://api.reuse.software/badge/github.com/damian-buho/r8e-http-cache)](https://api.reuse.software/info/github.com/damian-buho/r8e-http-cache)

![Project status](https://badges.kiota.ch/static/v1?label=status&message=maintained&color=1d63ed&style=flat-square) [![Last commit on GitHub](https://badges.kiota.ch/github/last-commit/damian-buho/r8e-http-cache?label=last%20commit%20on%20GitHub&style=flat-square)](https://github.com/damian-buho/r8e-http-cache) [![Last commit on kiota.ch](https://badges.kiota.ch/gitea/last-commit/r8e/http-cache?gitea_url=https://kiota.ch&label=last%20commit%20on%20kiota.ch&style=flat-square)](https://kiota.ch/r8e/http-cache)

[![Publish pipeline on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/published.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Vulnerability audit on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/audited.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Dependency freshness on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions) [![Analysis sweep on GitHub](https://github.com/damian-buho/r8e-http-cache/actions/workflows/analyzed.yaml/badge.svg?style=flat-square)](https://github.com/damian-buho/r8e-http-cache/actions)

[![Publish pipeline on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/published.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Vulnerability audit on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/audited.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Dependency freshness on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/check-outdated.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions) [![Analysis sweep on kiota.ch](https://kiota.ch/r8e/http-cache/badges/workflows/analyzed.yaml/badge.svg?style=flat-square)](https://kiota.ch/r8e/http-cache/actions)

## Можливості

- Створено для великих CI-артефактів
- Універсальний кешуючий HTTP-проксі
- Працює, коли ориджини лежать
- Безпечний спільний кеш

Також успадковує можливості B19 / Ubuntu — повний перелік див. у [Можливості](FEATURES.md).

## Швидкий старт

Збережіть це як `compose.yaml`:

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

Потім запустіть його командою `docker compose up --detach`.

## Що надає цей проєкт

- **Служба** `http-cache` — слухає на `8080 (http)` — Кешувальний HTTP-проксі
- **Образ контейнера** `ghcr.io/damian-buho/r8e/http-cache:latest`
- **Образ контейнера** `damianbuho/r8e-http-cache:latest`

## Встановлення

Завантажте опублікований образ контейнера:

### Завантажити з GHCR — linux/amd64, linux/arm64

```sh
docker pull ghcr.io/damian-buho/r8e/http-cache:latest
```

### Завантажити з DockerHub — linux/amd64

```sh
docker pull damianbuho/r8e-http-cache:latest
```

Стабільні випуски також публікують теґи `X.Y.Z`, `X.Y` і `X` — завантажте той рівень точності, який хочете зафіксувати.

Якщо наведені вище реєстри недоступні, завантажте з джерела:

### Завантажити з Kiota — linux/amd64

```sh
docker pull kiota.ch/r8e/http-cache:latest
```

## Використання

Запустіть сервіс у фоновому режимі, опублікувавши його порти:

### З GHCR

```sh
docker run --detach --publish 8080:8080/tcp ghcr.io/damian-buho/r8e/http-cache:latest
```

### З DockerHub

```sh
docker run --detach --publish 8080:8080/tcp damianbuho/r8e-http-cache:latest
```

## Збирання

Клонуйте репозиторій разом із підмодулями:

```sh
git clone --recurse-submodules https://github.com/damian-buho/r8e-http-cache http-cache && cd http-cache
```

Зберіть образ контейнера локально:

```sh
make container-build
```

- [Довідник із Makefile](../how-to/MAKEFILE.md)

Виконайте `make` без аргументів для типової цілі; виконайте `make help`, щоб переглянути всі цілі.

Для локального циклу розробки `make dev-container` піднімає dev-container.

Точки входу конвеєра:

- `make analyzed` — Запускає важкий аналіз (мутаційне тестування, бенчмарки)
- `make audited` — Повторно сканує закріплені залежності й опубліковані артефакти на нові вразливості
- `make check-outdated` — Звітує про кожну закріплену залежність, що відстає від upstream
- `make ready-to-publish` — Запускає псевдо-CI локально — збирає, тестує й сканує без публікації

## Політики

- [Як зробити внесок](CONTRIBUTING.md)
- [Політика безпеки](SECURITY.md)
- [Як отримати підтримку](SUPPORT.md)
- [Кодекс поведінки](CODE_OF_CONDUCT.md)
- [Політика щодо ШІ та LLM](AI_POLICY.md)

## Посилання

- [Специфікація Projectfile](https://projectfile.org)

## Ліцензія

Цей проєкт ліцензовано на умовах MIT — див. файл [LICENSE](LICENSE) для подробиць.

<!-- textlint-enable -->
