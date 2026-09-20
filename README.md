# Smart Money Concepts

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](CHANGELOG.md)
[![MT5](https://img.shields.io/badge/MT5-indicator%20%2B%20EA-blue.svg)](#metatrader-5)
[![Indie](https://img.shields.io/badge/Indie-v5-green.svg)](https://takeprofit.com/docs/indie)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Port **Smart Money Concepts** (BOS/CHoCH, Order Block, FVG, Premium/Discount) tanpa branding pihak ketiga.

Overlay chart dan alert Telegram memakai **satu engine** (`CSmcEngine`). Matikan gambar di chart tidak mengubah angka yang dipakai sinyal.

| | |
|---|---|
| **Versi** | `1.1.0` |
| **MT5** | Indikator `SMC` + EA `SMC_Scanner` |
| **Exness** | [`smc.indie`](smc.indie) (TakeProfit Indie v5) |

---

## Isi repo

Clone ke `MQL5/Experts/Smart Money Concepts`.

```
Smart Money Concepts/
├── SMC_Scanner.mq5              # EA scanner Telegram (pasang di chart)
├── SMC_Smoke.mq5                # self-test Strategy Tester (bukan scanner)
├── Include/                     # engine, draw, confluence, Telegram, dedup
├── Indicators/SMC.mq5           # overlay — copy ke MQL5/Indicators/
├── Scripts/Test_SmcEngine.mq5   # self-test — copy ke MQL5/Scripts/
├── Tester/smc_smoke.ini         # config tester untuk SMC_Smoke
└── smc.indie                    # indikator Exness Terminal
```

| File | Fungsi |
|------|--------|
| `SMC_Scanner` | Notifikasi zona (tidak membuka order) |
| `SMC` | Gambar BOS/CHoCH/OB/FVG di chart |
| `SMC_Smoke` | Tes otomatis di Strategy Tester |
| `SMC_Test_SmcEngine` | Tes yang sama, dijalankan sebagai script Navigator |

---

## MetaTrader 5

### Instalasi

1. Clone repo ini ke `MQL5/Experts/Smart Money Concepts`.
2. Salin `Indicators/SMC.mq5` → `MQL5/Indicators/SMC.mq5`.
3. Salin `Scripts/Test_SmcEngine.mq5` → `MQL5/Scripts/SMC_Test_SmcEngine.mq5` (opsional).
4. Compile di MetaEditor:
   - `MQL5/Indicators/SMC.mq5`
   - `MQL5/Experts/Smart Money Concepts/SMC_Scanner.mq5`
   - opsional: `SMC_Smoke.mq5` dan `SMC_Test_SmcEngine.mq5`

Kedua file salinan sudah meng-include engine di folder Experts ini. Jangan compile overlay dari dalam folder Experts — Navigator hanya memuat `MQL5/Indicators`.

### Overlay `SMC`

- `InpShowDrawings` — tampilkan atau sembunyikan object `SMC:`. Engine tetap dihitung.
- Max Structure Drawings default **10** (BOS/CHoCH lama tidak menumpuk tanpa batas).
- Default selaras alert: FVG **on**, auto threshold **off**, extend **5**, Premium/Discount **on**.
- Candle tidak diwarnai ulang.

Pasang ke chart (mis. XAUUSD M15) dari Navigator → Indicators → **SMC**.

### Scanner `SMC_Scanner` (Telegram, tanpa order)

Tidak ada TP, SL, lot, atau `OrderSend`. Hanya **entri zona + bias tren**.

**Default scan**

- Pair: `EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,USDCAD,NZDUSD,XAUUSD` (suffix broker di-resolve)
- TF sinyal: `M15,M30,H1,H4`
- Bias: H4; sinyal H4 memakai bias **D1**
- Drawing di chart EA default **off**

**BUY:** bias HTF bullish + harga di Discount + Swing/Internal OB atau FVG bullish yang masih aktif.  
**SELL:** bias HTF bearish + harga di Premium + OB/FVG bearish aktif.

Satu zona = satu Telegram (rising-edge). Kunci terkirim disimpan di `Common/Files/smc_sent_keys.csv`. Harga yang sudah di dalam zona saat EA di-attach tidak di-spam.

### Telegram

1. BotFather → token. Tambahkan bot ke channel sebagai **admin** (Post messages), atau ke group forum.
2. Tools → Options → Expert Advisors → Allow WebRequest: `https://api.telegram.org`
3. Input EA:
   - `InpTgBotToken`
   - `InpTgChatId` — `@channel` atau `-100xxxxxxxxxx`
   - `InpTgTopicId` — `0` = channel/chat; `>0` = topik forum (`message_thread_id`)
4. Link topik `https://t.me/c/2412345678/42` → ChatId `-1002412345678`, TopicId `42`.
5. `InpTgTestOnInit` mengirim pesan tes (bukan sinyal).

Format sinyal:

```text
🟢 SMC BUY · XAUUSD · M15

📈 Bias H4: Bullish
🎯 Entry: Discount
📦 Zone: Swing OB
📏 Range: 2345.20 – 2348.80
💵 Price: 2346.55
```

---

## Tes

Strategy Tester: Expert `Smart Money Concepts\SMC_Smoke`, config [`Tester/smc_smoke.ini`](Tester/smc_smoke.ini). Hasil `pass=` / `fail=` ditulis ke `Common/Files/smc_smoke_result.txt`.

Atau tarik script `SMC_Test_SmcEngine` ke chart. Journal harus `SMC tests passed`.

---

## Exness Terminal (Indie)

1. Buka **Exness Terminal (Web)** dan login.
2. Indicators → script Indie baru → paste [`smc.indie`](smc.indie).
3. Save / Compile, apply ke chart.

Custom indicator Indie **hanya** jalan di akun **MT5** yang bisa dibuka di Exness Terminal. Akun **Exness Terminal Only** tidak mendukung custom indicator.

Default Indie (FVG/zones off, extend 1) **berbeda** dari default overlay MT5. Untuk parity dengan scanner, pakai indikator MT5.

---

## Disclaimer

Alat bantu analisis teknikal. Bukan saran investasi. Trading melibatkan risiko kerugian.
