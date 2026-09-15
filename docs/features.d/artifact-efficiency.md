<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

# Built for large CI artifacts

- Concurrent range downloads of one file share cache entries instead of each filling its own.
- Tracking parameters never fork cache entries, while signed URLs still cache apart.
- Hit ratio is measurable out of the box through the status endpoint and cache-aware logs.
