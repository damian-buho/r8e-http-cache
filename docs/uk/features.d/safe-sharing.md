<!--
SPDX-FileCopyrightText: 2026 Damián Búho <damian.buho@proton.me>

SPDX-License-Identifier: MIT
-->

<!-- textlint-disable terminology,common-misspellings -->

# Безпечний спільний кеш

- Allowlist із забороною за замовчуванням: через проксі можна отримати лише налаштовані апстрими.
- Ретранслюються лише кешовані методи, а внутрішні чи метадані-адреси ніколи недосяжні.
- Ворожі форми хоста (трюки з userinfo, кінцеві крапки, хибні порти) відхиляються ще до контакту з ориджином.

<!-- textlint-enable -->
