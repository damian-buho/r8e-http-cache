<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Proxy de caché HTTP genérico

- Almacena en caché cualquier origen HTTPS: pasa una ruta URL con el host destino y el proxy obtiene, almacena y sirve la respuesta.
- Las redirecciones se siguen internamente, así los clientes siempre reciben el contenido final en lugar de rebotar entre orígenes.
- El estado de la caché es visible en las cabeceras de respuesta (X-Cache-Status, X-Upstream-Host, X-Upstream-Target), lo que simplifica el diagnóstico de aciertos y fallos.
- Entradas de larga vida con bloqueo y revalidación en segundo plano protegen a los orígenes de las avalanchas de peticiones.
- Enrutamiento integrado con Traefik: la caché se descubre a través de la capa de ingress estándar.

<!-- textlint-enable -->
