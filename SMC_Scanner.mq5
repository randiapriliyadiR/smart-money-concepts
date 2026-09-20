#property copyright   "Smart Money Concepts"
#property link        ""
#property version     "1.1.0"
#property description "Multi-pair SMC scanner. Telegram on confluence entry. No orders, no TP/SL."
#property strict

#include "Include/SmcTypes.mqh"
#include "Include/SmcEngine.mqh"
#include "Include/SmcDraw.mqh"
#include "Include/SmcConfluence.mqh"
#include "Include/SmcDedup.mqh"
#include "Include/SmcTelegram.mqh"

input group "Scan"
input string            InpSymbols        = "EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,USDCAD,NZDUSD,XAUUSD";
input string            InpSignalTfs      = "M15,M30,H1,H4";
input ENUM_TIMEFRAMES   InpBiasTf         = PERIOD_H4;
input int               InpCalcBars       = 500;
input int               InpTimerMs        = 1000;

input group "Chart"
input bool              InpShowDrawings   = false;

input group "Confluence"
input bool              InpUseSwingOB     = true;
input bool              InpUseInternalOB  = true;
input bool              InpUseFvg         = true;

input group "Telegram"
input string            InpTgBotToken     = "";
input string            InpTgChatId       = "";
input int               InpTgTopicId      = 0;
input bool              InpTgTestOnInit   = true;
input bool              InpTgSilent       = false;

#define SMC_MAX_SYM 16
#define SMC_MAX_TF  8
#define SMC_MAX_ENG 80

string            g_symbols[];
int               g_symN;
ENUM_TIMEFRAMES   g_sigTf[];
int               g_tfN;
int               g_rr;
CSmcDedup         g_dedup;
CSmcTelegram      g_tg;
CSmcDraw          g_draw;
SSmcConfluenceCfg g_cfg;

string            g_engKey[SMC_MAX_ENG];
CSmcEngine        g_eng[SMC_MAX_ENG];
datetime          g_engBar[SMC_MAX_ENG];
SSmcSnapshot      g_engSnap[SMC_MAX_ENG];
int               g_engN;

int SmcSplitList(const string raw, string &out[])
  {
   string tmp = raw;
   StringReplace(tmp, " ", "");
   StringReplace(tmp, ";", ",");
   ushort sep = StringGetCharacter(",", 0);
   int n = StringSplit(tmp, sep, out);
   int w = 0;
   for(int i = 0; i < n; i++)
     {
      StringTrimLeft(out[i]);
      StringTrimRight(out[i]);
      if(StringLen(out[i]) == 0)
         continue;
      out[w++] = out[i];
     }
   ArrayResize(out, w);
   return w;
  }

void SmcEngineSettings(SSmcSettings &s)
  {
   SmcSettingsDefault(s);
   s.calcBars = InpCalcBars;
   s.fvgAutoThreshold = false;
   s.fvgExtend = SMC_DEFAULT_FVG_EXTEND;
   s.showFvg = true;
   s.showZones = true;
   s.showInternalOb = true;
   s.showSwingOb = true;
   s.showSwing = true;
   s.showInternal = true;
   s.showStrongWeak = true;
  }

int SmcEngIndex(const string symbol, const ENUM_TIMEFRAMES tf, const bool create)
  {
   string key = symbol + "|" + IntegerToString((int)tf);
   for(int i = 0; i < g_engN; i++)
      if(g_engKey[i] == key)
         return i;
   if(!create || g_engN >= SMC_MAX_ENG)
      return -1;
   int i = g_engN++;
   g_engKey[i] = key;
   g_engBar[i] = 0;
   SSmcSettings s;
   SmcEngineSettings(s);
   g_eng[i].Init(s);
   SmcSnapshotClear(g_engSnap[i]);
   return i;
  }

bool SmcRefreshEngine(const string symbol, const ENUM_TIMEFRAMES tf)
  {
   int idx = SmcEngIndex(symbol, tf, true);
   if(idx < 0)
      return false;
   datetime t = iTime(symbol, tf, 0);
   if(t == 0)
      return false;
   if(g_engBar[idx] == t && g_engSnap[idx].swingBias != 0)
     {
      // still refresh trailing on same bar via full process is expensive; skip
     }
   if(g_engBar[idx] == t)
      return true;
   MqlRates rates[];
   int got = SmcCopyRates(symbol, tf, InpCalcBars, rates);
   if(got < 30)
      return false;
   if(!g_eng[idx].Process(rates))
      return false;
   double pdh, pdl, pwh, pwl, pmh, pml;
   datetime pdt, pwt, pmt;
   SmcPrevPeriodHL(symbol, PERIOD_D1, tf, pdh, pdl, pdt);
   SmcPrevPeriodHL(symbol, PERIOD_W1, tf, pwh, pwl, pwt);
   SmcPrevPeriodHL(symbol, PERIOD_MN1, tf, pmh, pml, pmt);
   g_eng[idx].SetPrevPeriodLevels(pdh, pdl, pdt, pwh, pwl, pwt, pmh, pml, pmt);
   g_eng[idx].GetSnapshot(g_engSnap[idx]);
   g_engBar[idx] = t;
   return true;
  }

bool SmcGetSnap(const string symbol, const ENUM_TIMEFRAMES tf, SSmcSnapshot &snap)
  {
   if(!SmcRefreshEngine(symbol, tf))
      return false;
   int idx = SmcEngIndex(symbol, tf, false);
   if(idx < 0)
      return false;
   snap = g_engSnap[idx];
   return true;
  }

void SmcFillAlertFromBox(SSmcAlert &alert, const SSmcBox &box, const ENUM_SMC_ZONE kind,
                         const ENUM_SMC_DIR dir, const ENUM_SMC_PD pd, const int bias,
                         const string symbol, const ENUM_TIMEFRAMES signalTf, const ENUM_TIMEFRAMES biasTf,
                         const double price)
  {
   alert.valid = true;
   alert.dir = dir;
   alert.zone = kind;
   alert.pd = pd;
   alert.bias = bias;
   alert.signalTf = signalTf;
   alert.biasTf = biasTf;
   alert.price = price;
   alert.symbol = symbol;
   alert.zoneTime = box.t0;
   double top, bot;
   SmcBoxEdges(box, top, bot);
   alert.zoneHigh = top;
   alert.zoneLow = bot;
  }

void SmcScanSymbol(const string symbol)
  {
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   if(bid <= 0.0)
      return;
   for(int t = 0; t < g_tfN; t++)
     {
      ENUM_TIMEFRAMES sigTf = g_sigTf[t];
      ENUM_TIMEFRAMES biasTf = SmcBiasTfForSignal(sigTf, InpBiasTf);
      SSmcSnapshot biasSnap, sigSnap;
      if(!SmcGetSnap(symbol, biasTf, biasSnap))
         continue;
      if(!SmcGetSnap(symbol, sigTf, sigSnap))
         continue;
      ENUM_SMC_PD pd = SmcPdAt(biasSnap, bid);
      bool wantBuy = (biasSnap.swingBias == SMC_BULLISH && pd == SMC_PD_DISCOUNT);
      bool wantSell = (biasSnap.swingBias == SMC_BEARISH && pd == SMC_PD_PREMIUM);
      if(!wantBuy && !wantSell)
         continue;
      ENUM_SMC_DIR dir = wantBuy ? SMC_DIR_BUY : SMC_DIR_SELL;
      int want = wantBuy ? SMC_BULLISH : SMC_BEARISH;
      SSmcAlert sendAlert;
      string sendKey = "";
      bool haveSend = false;

      if(g_cfg.useSwingOb)
        {
         for(int i = 0; i < SMC_OB_POOL; i++)
           {
            if(!sigSnap.sOb[i].active || sigSnap.sOb[i].bias != want)
               continue;
            SSmcAlert a;
            SmcFillAlertFromBox(a, sigSnap.sOb[i], SMC_ZONE_SWING_OB, dir, pd,
                                biasSnap.swingBias, symbol, sigTf, biasTf, bid);
            string key = SmcAlertKey(a);
            bool inside = SmcPriceInBox(sigSnap.sOb[i], bid);
            if(g_dedup.ShouldSend(key, inside) && !haveSend)
              {
               sendAlert = a;
               sendKey = key;
               haveSend = true;
              }
           }
        }
      if(g_cfg.useInternalOb)
        {
         for(int i = 0; i < SMC_OB_POOL; i++)
           {
            if(!sigSnap.iOb[i].active || sigSnap.iOb[i].bias != want)
               continue;
            SSmcAlert a;
            SmcFillAlertFromBox(a, sigSnap.iOb[i], SMC_ZONE_INT_OB, dir, pd,
                                biasSnap.swingBias, symbol, sigTf, biasTf, bid);
            string key = SmcAlertKey(a);
            bool inside = SmcPriceInBox(sigSnap.iOb[i], bid);
            if(g_dedup.ShouldSend(key, inside) && !haveSend)
              {
               sendAlert = a;
               sendKey = key;
               haveSend = true;
              }
           }
        }
      if(g_cfg.useFvg)
        {
         for(int i = 0; i < SMC_FVG_POOL; i++)
           {
            if(!sigSnap.fvg[i].active || sigSnap.fvg[i].bias != want)
               continue;
            SSmcAlert a;
            SmcFillAlertFromBox(a, sigSnap.fvg[i], SMC_ZONE_FVG, dir, pd,
                                biasSnap.swingBias, symbol, sigTf, biasTf, bid);
            string key = SmcAlertKey(a);
            bool inside = SmcPriceInBox(sigSnap.fvg[i], bid);
            if(g_dedup.ShouldSend(key, inside) && !haveSend)
              {
               sendAlert = a;
               sendKey = key;
               haveSend = true;
              }
           }
        }
      if(haveSend)
        {
         if(g_tg.SendAlert(sendAlert))
            g_dedup.MarkSent(sendKey);
        }
     }
  }

void SmcMaybeDrawChart(void)
  {
   if(!InpShowDrawings)
     {
      g_draw.Clear();
      return;
     }
   ENUM_TIMEFRAMES ctf = (ENUM_TIMEFRAMES)Period();
   bool okTf = (ctf == InpBiasTf);
   for(int i = 0; i < g_tfN; i++)
      if(g_sigTf[i] == ctf)
         okTf = true;
   if(!okTf)
      return;
   SSmcSnapshot snap;
   if(!SmcGetSnap(_Symbol, ctf, snap))
      return;
   SSmcSettings s;
   SmcEngineSettings(s);
   g_draw.Configure(s, SMC_CLR_GREEN, SMC_CLR_RED, SMC_CLR_GREEN, SMC_CLR_RED,
                    SMC_CLR_IOB_BULL, SMC_CLR_IOB_BEAR, SMC_CLR_SOB_BULL, SMC_CLR_SOB_BEAR,
                    SMC_CLR_FVG_BULL, SMC_CLR_FVG_BEAR, SMC_CLR_RED, SMC_CLR_GRAY, SMC_CLR_GREEN,
                    SMC_CLR_BLUE, SMC_CLR_BLUE, SMC_CLR_BLUE,
                    SMC_LINE_SOLID, SMC_LINE_SOLID, SMC_LINE_SOLID,
                    SMC_FONT_TINY, SMC_FONT_SMALL, SMC_FONT_TINY);
   g_draw.Render(snap, _Symbol);
  }

int OnInit()
  {
   g_engN = 0;
   g_rr = 0;
   g_symN = 0;
   g_tfN = 0;
   SmcConfluenceDefault(g_cfg);
   g_cfg.useSwingOb = InpUseSwingOB;
   g_cfg.useInternalOb = InpUseInternalOB;
   g_cfg.useFvg = InpUseFvg;

   string raw[];
   int n = SmcSplitList(InpSymbols, raw);
   ArrayResize(g_symbols, 0);
   for(int i = 0; i < n && g_symN < SMC_MAX_SYM; i++)
     {
      string s = SmcResolveSymbol(raw[i]);
      if(s == "")
         continue;
      if(!SymbolSelect(s, true))
        {
         Print("SMC skip symbol ", raw[i]);
         continue;
        }
      int sz = ArraySize(g_symbols);
      ArrayResize(g_symbols, sz + 1);
      g_symbols[sz] = s;
      g_symN++;
     }

   string tfs[];
   int nt = SmcSplitList(InpSignalTfs, tfs);
   ArrayResize(g_sigTf, 0);
   for(int i = 0; i < nt && g_tfN < SMC_MAX_TF; i++)
     {
      ENUM_TIMEFRAMES tf = SmcTfFromString(tfs[i]);
      if(tf == PERIOD_CURRENT)
         tf = (ENUM_TIMEFRAMES)Period();
      int sz = ArraySize(g_sigTf);
      ArrayResize(g_sigTf, sz + 1);
      g_sigTf[sz] = tf;
      g_tfN++;
     }

   if(g_symN == 0 || g_tfN == 0)
     {
      Print("SMC Scanner: no symbols or timeframes");
      return INIT_FAILED;
     }

   g_dedup.Load();
   g_tg.Configure(InpTgBotToken, InpTgChatId, InpTgTopicId, InpTgSilent);
   if(InpTgTestOnInit)
     {
      if(!g_tg.Ready())
         Print("SMC Scanner: Telegram not configured (token/chat). Scanner still runs.");
      else if(g_tg.SendOnline(InpSymbols, InpBiasTf, InpSignalTfs))
         Print("SMC Scanner: Telegram test ok");
      else
         Print("SMC Scanner: Telegram test failed — ", g_tg.LastError());
     }

   EventSetMillisecondTimer(MathMax(200, InpTimerMs));
   Print("SMC Scanner v", SMC_VERSION, " symbols=", g_symN, " tfs=", g_tfN);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   g_draw.Clear();
  }

void OnTick()
  {
  }

void OnTimer()
  {
   if(g_symN <= 0)
      return;
   int idx = g_rr % g_symN;
   g_rr++;
   SmcScanSymbol(g_symbols[idx]);
   if(InpShowDrawings)
      SmcMaybeDrawChart();
  }
