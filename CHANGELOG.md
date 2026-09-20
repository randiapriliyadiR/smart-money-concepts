# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-09-20

### Added

- MT5 overlay indicator `SMC.mq5` using the same engine as the scanner (BOS/CHoCH, OB, FVG, Premium/Discount, EQHL, D/W/M)
- `SMC_Scanner.mq5` multi-pair Telegram scanner (no orders, no TP/SL)
- Shared `CSmcEngine` + `CSmcSnapshot` so chart drawings and alerts cannot diverge
- One-shot dedup (rising-edge zone entry, persist sent keys)
- Telegram channel + forum topic (`message_thread_id`)
- Script `Scripts/Test_SmcEngine.mq5` / Navigator `SMC_Test_SmcEngine`
- Strategy Tester smoke EA `SMC_Smoke.mq5` (`Tester/smc_smoke.ini`)

### Changed

- MT5 FVG defaults for signal parity: **on**, auto threshold **off**, extend **5**
- MT5 Premium/Discount zones **on** by default so the overlay matches alerts
- README: catatan akun **MT5** vs **Exness Terminal Only** for custom Indie indicators

### Fixed

- Engine accepts short series (FVG needs 3 bars; previously rejected under 10)
- Dedup self-test is isolated so it cannot write `TEST|` keys into live `smc_sent_keys.csv`

### Removed

- `smc-luxalgo.ts` Pine reference (runtime source of truth is `smc.indie` / `CSmcEngine`)

## [1.0.1] - 2026-09-03

### Changed

- Swing Order Blocks now **on** by default (matches LuxAlgo Pine defaults)
- OB pool increased from 6 → 8 (more OB zones visible, esp. older swing OBs)
- Internal & Swing OB count default raised to 5 (max 8)

### Fixed

- Swing OB zones that were far from current price now appear (previously dropped by small pool)

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

[1.1.0]: https://github.com/randiapriliyadiR/smart-money-concepts/releases/tag/v1.1.0
[1.0.1]: https://github.com/randiapriliyadiR/smart-money-concepts/releases/tag/v1.0.1
[1.0.0]: https://github.com/randiapriliyadiR/smart-money-concepts/releases/tag/v1.0.0
