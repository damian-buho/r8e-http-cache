<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Safe shared caching

- Default-deny allowlist: only configured upstreams can be fetched through the proxy.
- Only cacheable methods are relayed, and interior or metadata targets are never reachable.
- Hostile host shapes (userinfo tricks, trailing dots, bad ports) are refused before any upstream contact.
