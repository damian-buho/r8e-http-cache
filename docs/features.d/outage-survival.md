<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Serves through upstream outages

- Expired entries keep serving as stale while an origin is down, instead of failing every client.
- The cache persists across restarts on a dedicated volume, so a restart never means starting cold.
- Disk use is bounded with LRU eviction, and the in-memory index is sized for registry-scale fan-out.
- Health stays green during outside outages by design: the cache keeps serving stale instead of restarting into an empty index.
