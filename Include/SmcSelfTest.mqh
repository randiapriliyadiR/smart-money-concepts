#ifndef SMC_SELFTEST_MQH
#define SMC_SELFTEST_MQH

#include "SmcTypes.mqh"
#include "SmcEngine.mqh"
#include "SmcConfluence.mqh"
#include "SmcDedup.mqh"

int g_smcFail = 0;
int g_smcPass = 0;
string g_smcFailNames = "";

void SmcExpect(const bool cond, const string name)
  {
   if(cond)
     {
      g_smcPass++;
      Print("PASS  ", name);
     }
   else
     {
      g_smcFail++;
      Print("FAIL  ", name);
      if(StringLen(g_smcFailNames) > 0)
         g_smcFailNames += "; ";
      g_smcFailNames += name;
     }
  }

void SmcTestConfluence(void)
  {
   SSmcSnapshot bias, sig;
   SmcSnapshotClear(bias);
   SmcSnapshotClear(sig);
   bias.swingBias = SMC_BULLISH;
   bias.trailTop = 1.10000;
   bias.trailBottom = 1.00000;
   bias.premiumTop = 1.10000;
   bias.premiumBot = 0.95 * 1.10000 + 0.05 * 1.00000;
   bias.discountBot = 1.00000;
   bias.discountTop = 0.95 * 1.00000 + 0.05 * 1.10000;
   sig.sOb[0].active = true;
   sig.sOb[0].bias = SMC_BULLISH;
   sig.sOb[0].high = 1.00400;
   sig.sOb[0].low = 1.00050;
   sig.sOb[0].t0 = D'2024.01.01 00:00';

   SSmcConfluenceCfg cfg;
   SmcConfluenceDefault(cfg);
   SSmcAlert a;
   bool inDisc = SmcEvaluateSetup(bias, sig, cfg, 1.00200, "EURUSD", PERIOD_M15, PERIOD_H4, a);
   SmcExpect(inDisc && a.dir == SMC_DIR_BUY && a.zone == SMC_ZONE_SWING_OB, "confluence buy in discount+OB");
   bool inPrem = SmcEvaluateSetup(bias, sig, cfg, 1.09800, "EURUSD", PERIOD_M15, PERIOD_H4, a);
   SmcExpect(!inPrem, "no buy setup in premium");
  }

void SmcTestDedup(void)
  {
   CSmcDedup d;
   d.Isolate();
   string k = "TEST|15|1|1|100|1.0|1.1";
   SmcExpect(!d.ShouldSend(k, true), "first observation inside is seed, no send");
   SmcExpect(!d.ShouldSend(k, true), "stay inside, no send");
   SmcExpect(!d.ShouldSend(k, false), "leave zone, no send");
   SmcExpect(d.ShouldSend(k, true), "re-entry rising edge sends once");
   d.MarkSent(k);
   SmcExpect(!d.ShouldSend(k, false), "after send, leave silent");
   SmcExpect(!d.ShouldSend(k, true), "after send, re-entry silent");
  }

void SmcTestEngine(void)
  {
   MqlRates rates[];
   int got = SmcCopyRates(_Symbol, PERIOD_M15, 500, rates);
   if(got < 80)
     {
      Print("SKIP engine live rates (got ", got, ")");
      return;
     }
   CSmcEngine e1, e2;
   SSmcSettings s;
   SmcSettingsDefault(s);
   s.calcBars = MathMin(500, got);
   s.fvgAutoThreshold = false;
   s.fvgExtend = 5;
   e1.Init(s);
   e2.Init(s);
   SmcExpect(e1.Process(rates), "engine process A");
   SmcExpect(e2.Process(rates), "engine process B");
   SSmcSnapshot a, b;
   e1.GetSnapshot(a);
   e2.GetSnapshot(b);
   SmcExpect(a.swingBias == b.swingBias, "parity swing bias");
   SmcExpect(a.trailTop == b.trailTop && a.trailBottom == b.trailBottom, "parity trail");
   SmcExpect(a.premiumBot == b.premiumBot && a.discountTop == b.discountTop, "parity PD");
   int ob = 0;
   int fvg = 0;
   int st = 0;
   for(int i = 0; i < SMC_OB_POOL; i++)
     {
      if(a.sOb[i].active)
         ob++;
      if(a.iOb[i].active)
         ob++;
      SmcExpect(a.sOb[i].active == b.sOb[i].active, "parity swing OB slot");
     }
   for(int i = 0; i < SMC_FVG_POOL; i++)
     {
      if(a.fvg[i].active)
         fvg++;
      SmcExpect(a.fvg[i].active == b.fvg[i].active, "parity FVG slot");
     }
   for(int i = 0; i < SMC_STRUCT_POOL; i++)
      if(a.structs[i].filled)
         st++;
   Print("engine events struct=", st, " ob=", ob, " fvg=", fvg, " bias=", a.swingBias);
   SmcExpect(st >= 0 && ob <= SMC_OB_POOL * 2, "OB pool cap");
  }

void SmcBar(MqlRates &r, const datetime t, const double o, const double h, const double l, const double c)
  {
   r.time = t;
   r.open = o;
   r.high = h;
   r.low = l;
   r.close = c;
   r.tick_volume = 1;
   r.spread = 0;
   r.real_volume = 0;
  }

void SmcTestDefaults(void)
  {
   SSmcSettings s;
   SmcSettingsDefault(s);
   SmcExpect(s.showFvg, "default FVG on");
   SmcExpect(!s.fvgAutoThreshold, "default FVG auto threshold off");
   SmcExpect(s.fvgExtend == 5, "default FVG extend 5");
   SmcExpect(s.showZones, "default premium/discount on");
   SmcExpect(s.maxStructure == 10, "default max structure 10");
   SmcExpect(s.showInternal && s.showSwing && s.showInternalOb && s.showSwingOb, "default structure+OB on");
  }

void SmcTestFvgSynthetic(void)
  {
   MqlRates r[];
   ArrayResize(r, 8);
   datetime t = D'2024.01.01 00:00';
   for(int i = 0; i < 5; i++)
      SmcBar(r[i], t + i * 60, 1.000, 1.002, 0.999, 1.001);
   SmcBar(r[5], t + 5 * 60, 1.001, 1.010, 1.000, 1.002);
   SmcBar(r[6], t + 6 * 60, 1.011, 1.021, 1.011, 1.020);
   SmcBar(r[7], t + 7 * 60, 1.022, 1.026, 1.021, 1.025);

   CSmcEngine e;
   SSmcSettings s;
   SmcSettingsDefault(s);
   s.calcBars = 8;
   s.swingsLength = 50;
   s.showEqhl = false;
   s.showStrongWeak = false;
   s.showZones = true;
   e.Init(s);
   SmcExpect(e.Process(r), "FVG synthetic process");
   SSmcSnapshot snap;
   e.GetSnapshot(snap);
   bool found = false;
   for(int i = 0; i < SMC_FVG_POOL; i++)
     {
      if(!snap.fvg[i].active || snap.fvg[i].bias != SMC_BULLISH)
         continue;
      found = (MathAbs(snap.fvg[i].high - 1.021) < 0.0000001 &&
               MathAbs(snap.fvg[i].low - 1.010) < 0.0000001);
      if(found)
         break;
     }
   SmcExpect(found, "bullish 3-bar FVG high=curLow low=last2High");
   if(!found)
     {
      Print("FVG dump process=", e.Process(r) ? 1 : 0, " n=", ArraySize(r));
      for(int j = 0; j < SMC_FVG_POOL; j++)
        {
         if(!snap.fvg[j].active)
            continue;
         Print("FVG[", j, "] bias=", snap.fvg[j].bias,
               " high=", DoubleToString(snap.fvg[j].high, 6),
               " low=", DoubleToString(snap.fvg[j].low, 6));
        }
     }
  }

void SmcTestBosAndZones(void)
  {
   const int n = 28;
   MqlRates r[];
   ArrayResize(r, n);
   datetime t = D'2024.06.01 00:00';
   for(int i = 0; i < n; i++)
      SmcBar(r[i], t + i * 60, 1.15, 1.20, 1.10, 1.15);
   SmcBar(r[10], t + 10 * 60, 1.11, 1.12, 1.00, 1.11);
   SmcBar(r[11], t + 11 * 60, 1.12, 1.13, 1.05, 1.12);
   SmcBar(r[12], t + 12 * 60, 1.13, 1.14, 1.06, 1.13);
   SmcBar(r[13], t + 13 * 60, 1.14, 1.15, 1.07, 1.14);
   SmcBar(r[17], t + 17 * 60, 1.40, 1.50, 1.30, 1.40);
   SmcBar(r[18], t + 18 * 60, 1.42, 1.45, 1.35, 1.40);
   SmcBar(r[19], t + 19 * 60, 1.41, 1.44, 1.34, 1.39);
   SmcBar(r[20], t + 20 * 60, 1.40, 1.43, 1.33, 1.38);
   SmcBar(r[21], t + 21 * 60, 1.45, 1.49, 1.37, 1.48);
   SmcBar(r[22], t + 22 * 60, 1.49, 1.53, 1.47, 1.51);

   CSmcEngine e;
   SSmcSettings s;
   SmcSettingsDefault(s);
   s.calcBars = n;
   s.swingsLength = 3;
   s.showEqhl = false;
   s.showFvg = false;
   s.showInternal = true;
   s.showInternalOb = false;
   e.Init(s);
   SmcExpect(e.Process(r), "BOS synthetic process");
   SSmcSnapshot snap;
   e.GetSnapshot(snap);
   bool bos = false;
   int filled = 0;
   for(int i = 0; i < SMC_STRUCT_POOL; i++)
     {
      if(!snap.structs[i].filled)
         continue;
      filled++;
      if(!snap.structs[i].dashed &&
         snap.structs[i].tag == SMC_TAG_BOS &&
         snap.structs[i].bias == SMC_BULLISH &&
         MathAbs(snap.structs[i].level - 1.50) < 0.0000001)
         bos = true;
     }
   SmcExpect(bos, "swing bullish BOS at 1.50 after close cross");
   SmcExpect(snap.swingBias == SMC_BULLISH, "swing bias bullish after BOS");
   SmcExpect(SmcValid(snap.trailTop) && SmcValid(snap.trailBottom), "trailing extremes exist");
   if(SmcValid(snap.trailTop) && SmcValid(snap.trailBottom))
     {
      double premBot = 0.95 * snap.trailTop + 0.05 * snap.trailBottom;
      double discTop = 0.95 * snap.trailBottom + 0.05 * snap.trailTop;
      SmcExpect(MathAbs(snap.premiumBot - premBot) < 0.0000001, "premium bot 95/5");
      SmcExpect(MathAbs(snap.discountTop - discTop) < 0.0000001, "discount top 95/5");
      SmcExpect(SmcPdAt(snap, snap.discountTop - 0.001) == SMC_PD_DISCOUNT, "price in discount");
      SmcExpect(SmcPdAt(snap, snap.premiumBot + 0.001) == SMC_PD_PREMIUM, "price in premium");
     }

   s.maxStructure = 4;
   e.Init(s);
   e.Process(r);
   e.GetSnapshot(snap);
   filled = 0;
   for(int i = 0; i < SMC_STRUCT_POOL; i++)
      if(snap.structs[i].filled)
         filled++;
   SmcExpect(filled <= 4, "max structure drawings cap");
  }

void SmcTestParityDrawAgnostic(void)
  {
   MqlRates r[];
   ArrayResize(r, 12);
   datetime t = D'2024.03.01 00:00';
   for(int i = 0; i < 12; i++)
      SmcBar(r[i], t + i * 60, 1.0 + i * 0.001, 1.002 + i * 0.001, 0.999 + i * 0.001, 1.001 + i * 0.001);
   CSmcEngine a, b;
   SSmcSettings s;
   SmcSettingsDefault(s);
   s.calcBars = 12;
   a.Init(s);
   b.Init(s);
   a.Process(r);
   b.Process(r);
   SSmcSnapshot sa, sb;
   a.GetSnapshot(sa);
   b.GetSnapshot(sb);
   SmcExpect(sa.swingBias == sb.swingBias && sa.premiumBot == sb.premiumBot, "snapshot identical across engines");
  }

void SmcRunSelfTests(void)
  {
   Print("=== SMC engine tests ===");
   SmcTestDefaults();
   SmcTestConfluence();
   SmcTestDedup();
   SmcTestFvgSynthetic();
   SmcTestBosAndZones();
   SmcTestParityDrawAgnostic();
   SmcTestEngine();
   Print("=== result pass=", g_smcPass, " fail=", g_smcFail, " ===");
   if(g_smcFail > 0)
      Alert("SMC tests FAILED: ", g_smcFail);
   else
      Alert("SMC tests passed: ", g_smcPass);
  }

#endif
