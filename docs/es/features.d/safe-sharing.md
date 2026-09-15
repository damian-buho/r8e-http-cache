<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Caché compartida y segura

- Lista de permitidos con denegación por defecto: solo se pueden obtener los orígenes configurados.
- Solo se retransmiten los métodos cacheables, y los destinos internos o de metadatos nunca son alcanzables.
- Las formas hostiles de host (trucos con userinfo, puntos finales, puertos inválidos) se rechazan antes de contactar a ningún origen.

<!-- textlint-enable -->
