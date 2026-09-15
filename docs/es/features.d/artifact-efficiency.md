<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Pensada para artefactos grandes de CI

- Las descargas concurrentes por rangos de un mismo archivo comparten las entradas de caché en lugar de llenar una cada una.
- Los parámetros de rastreo nunca bifurcan las entradas de caché, mientras que las URLs firmadas se siguen cacheando por separado.
- La tasa de aciertos se puede medir desde el primer momento con el endpoint de estado y los logs conscientes de la caché.

<!-- textlint-enable -->
