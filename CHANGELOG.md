# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project uses [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-09-02

### Added

- Indie v5 Smart Money Concepts indicator for Exness / TakeProfit (`smc.indie`)
- Internal & Swing structure: BOS / CHoCH
- Internal & Swing Order Blocks with mitigation
- Equal Highs / Lows (EQH / EQL)
- Strong / Weak High & Low
- Fair Value Gaps (optional MTF)
- Daily / Weekly / Monthly levels (optional)
- Premium / Equilibrium / Discount zones (optional)
- Colored and Monochrome styles
- Drawing pools sized for Indie 100 drawing-changes-per-bar limit
- History reset on timeframe change (`bar_index == 0`)

### Notes

- Candles are not recolored (broker candle colors stay intact)
- Alerts from Pine `alertcondition` are not ported; use TakeProfit Cloud Alerts if needed
- Reference Pine script kept as `smc-luxalgo.ts` (not for Exness)

[1.0.0]: https://github.com/randiapriliyadiR/smart-money-concepts/releases/tag/v1.0.0
