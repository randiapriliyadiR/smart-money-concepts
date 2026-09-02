# Smart Money Concepts

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)
[![Indie](https://img.shields.io/badge/Indie-v5-green.svg)](https://takeprofit.com/docs/indie)
[![Platform](https://img.shields.io/badge/Exness-TakeProfit-orange.svg)](https://get.exness.help/hc/en-us/articles/27261267831068-Custom-indicators-in-Exness-Terminal)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Indikator **Smart Money Concepts (SMC)** untuk **Exness Terminal** (TakeProfit Indie).  
Port logika SMC murni — tanpa branding pihak ketiga.

| | |
|---|---|
| **Versi** | `1.0.0` |
| **Bahasa** | Indie v5 |
| **File utama** | [`smc.indie`](smc.indie) |
| **Platform** | Exness Terminal (Web) |

---

## Fitur

| Modul | Keterangan | Default |
|-------|------------|---------|
| Internal / Swing structure | **BOS** & **CHoCH** | On |
| Order Blocks | Internal (+ opsional Swing), dengan mitigasi | Internal on |
| EQH / EQL | Equal highs & lows | On |
| Strong / Weak HL | Label high & low | On |
| Fair Value Gaps | FVG multi-timeframe | Off |
| Daily / Weekly / Monthly | PDH/PDL, PWH/PWL, PMH/PML | Off |
| Premium / Discount | Zona premium, equilibrium, discount | Off |
| Style | Colored atau Monochrome | Colored |

Candle **tidak** diwarnai ulang — warna body mengikuti broker.

---

## Instalasi (Exness)

1. Buka **Exness Terminal (Web)** dan login.
2. Buka **Indicators** → buat script Indie baru.
3. Paste seluruh isi [`smc.indie`](smc.indie).
4. **Save / Compile**, lalu apply ke chart.
5. Jika ada error syntax, coba [TakeProfit AI for Exness](https://takeprofit.com/ai/exness).

> Setelah update script: hapus indikator lama dari chart, lalu apply ulang agar state drawing bersih.

---

## File proyek

```
smart-money-concepts/
├── smc.indie          # Indikator (paste ke Exness)
├── VERSION            # SemVer saat ini
├── CHANGELOG.md       # Riwayat rilis
├── LICENSE            # MIT
├── README.md
└── smc-luxalgo.ts     # Referensi Pine (bukan untuk Exness)
```

---

## Settings singkat

**Aktif by default:** Internal structure, Internal OB, EQH/EQL, Strong/Weak HL.

**Mati by default (aktifkan bila perlu):** Swing OB, FVG, Daily/Weekly/Monthly, Premium/Discount zones.

| Setting | Saran |
|---------|--------|
| Max Structure Drawings | Default `10` (max `12`) — turunkan jika chart berat |
| FVG timeframe | ≥ timeframe chart |
| Internal / Swing OB Count | Max `6` (batas pool Indie) |

---

## Performa & batasan Indie

TakeProfit membatasi **maks. 100 drawing changes per bar update**.

Yang sudah diterapkan:

- Pool drawing terbatas (structure ≤12, EQH/FVG/OB ≤6)
- `chart.draw` digabung di bar terakhir
- OB hanya yang aktif yang digambar
- Modul MTF (FVG / D-W-M) di-skip di `calc` jika dimatikan
- State di-reset saat recalc / ganti timeframe (`bar_index == 0`)

Agar lebih ringan:

1. Turunkan **Max Structure Drawings**
2. Matikan modul yang tidak dipakai
3. Hindari menyalakan FVG + Daily + Weekly + Monthly sekaligus

> Dengan pool terbatas, hanya **N structure terakhir** yang tampil (bukan seluruh history unlimited seperti Pine).

### Batasan lain

- `# indie:lang_version = 5`
- Field instance hanya boleh dibuat di top-level `__init__`
- Pine `alertcondition` tidak ada di Indie — gunakan Cloud Alerts TakeProfit
- Ganti TF = recalc penuh (normal)

---

## Verifikasi cepat

Pada chart contoh (mis. XAUUSD M15):

1. Internal BOS/CHoCH muncul (garis dashed).
2. Warna candle tetap default broker.
3. Toggle modul lain di settings → objek muncul sesuai toggle.
4. Ganti timeframe → indikator tetap muncul setelah recalc.
5. Zoom in/out → drawing tidak hilang.

---

## Versioning

Proyek memakai [Semantic Versioning](https://semver.org/):

| File | Isi |
|------|-----|
| [`VERSION`](VERSION) | `MAJOR.MINOR.PATCH` |
| [`CHANGELOG.md`](CHANGELOG.md) | Catatan tiap rilis |
| Git tag | `v1.0.0`, `v1.1.0`, … |

Rilis saat ini: **v1.0.0** (2026-09-02).

Header di `smc.indie` juga mencantumkan versi yang sama.

---

## Referensi

- [TakeProfit Indie Docs](https://takeprofit.com/docs/indie)
- [Drawings API](https://takeprofit.com/docs/indie/Plotting-and-drawing/Drawings-lines-labels)
- [Custom indicators di Exness](https://get.exness.help/hc/en-us/articles/27261267831068-Custom-indicators-in-Exness-Terminal)

---

## Disclaimer

Alat bantu analisis teknikal. Bukan saran investasi. Trading melibatkan risiko kerugian.
