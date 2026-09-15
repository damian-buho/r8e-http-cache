<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Generic HTTP caching proxy

- Caches any HTTPS upstream: pass a URL path with the target host and the proxy fetches, caches, and serves the response.
- Redirects are followed internally, so clients always receive the final content rather than being bounced between origins.
- Cache status is visible in response headers (X-Cache-Status, X-Upstream-Host, X-Upstream-Target), making hit/miss diagnosis straightforward.
- Long-lived entries with locking and background revalidation shield origins from thundering herds.
- Traefik-integrated routing makes the cache discoverable through the standard ingress layer.
