<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Sirve aunque los orígenes caigan

- Las entradas vencidas se siguen sirviendo como contenido obsoleto mientras el origen está caído, en lugar de fallar a cada cliente.
- La caché sobrevive a los reinicios en un volumen dedicado, así que reiniciar nunca significa empezar en frío.
- El uso de disco está acotado con desalojo LRU, y el índice en memoria está dimensionado para el abanico de registros de paquetes.
- La salud del contenedor se mantiene en verde durante cortes externos por diseño: la caché sigue sirviendo contenido obsoleto en vez de reiniciarse con el índice vacío.

<!-- textlint-enable -->
