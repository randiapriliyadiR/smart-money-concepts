#ifndef SMC_CONFLUENCE_MQH
#define SMC_CONFLUENCE_MQH

#include "SmcTypes.mqh"

struct SSmcConfluenceCfg
  {
   bool useSwingOb;
   bool useInternalOb;
   bool useFvg;
  };

void SmcConfluenceDefault(SSmcConfluenceCfg &c)
  {
   c.useSwingOb = true;
   c.useInternalOb = true;
   c.useFvg = true;
  }

bool SmcPickZone(const SSmcSnapshot &sig, const SSmcConfluenceCfg &cfg, const ENUM_SMC_DIR dir,
                 const double price, SSmcBox &box, ENUM_SMC_ZONE &kind)
  {
   kind = SMC_ZONE_NONE;
   ZeroMemory(box);
   int want = (dir == SMC_DIR_BUY) ? SMC_BULLISH : SMC_BEARISH;

   if(cfg.useSwingOb)
     {
      for(int i = 0; i < SMC_OB_POOL; i++)
        {
         if(!sig.sOb[i].active || sig.sOb[i].bias != want)
            continue;
         if(SmcPriceInBox(sig.sOb[i], price))
           {
            box = sig.sOb[i];
            kind = SMC_ZONE_SWING_OB;
            return true;
           }
        }
     }
   if(cfg.useInternalOb)
     {
      for(int i = 0; i < SMC_OB_POOL; i++)
        {
         if(!sig.iOb[i].active || sig.iOb[i].bias != want)
            continue;
         if(SmcPriceInBox(sig.iOb[i], price))
           {
            box = sig.iOb[i];
            kind = SMC_ZONE_INT_OB;
            return true;
           }
        }
     }
   if(cfg.useFvg)
     {
      for(int i = 0; i < SMC_FVG_POOL; i++)
        {
         if(!sig.fvg[i].active || sig.fvg[i].bias != want)
            continue;
         if(SmcPriceInBox(sig.fvg[i], price))
           {
            box = sig.fvg[i];
            kind = SMC_ZONE_FVG;
            return true;
           }
        }
     }
   return false;
  }

bool SmcEvaluateSetup(const SSmcSnapshot &biasSnap, const SSmcSnapshot &sigSnap,
                      const SSmcConfluenceCfg &cfg, const double price,
                      const string symbol, const ENUM_TIMEFRAMES signalTf, const ENUM_TIMEFRAMES biasTf,
                      SSmcAlert &alert)
  {
   alert.symbol = symbol;
   alert.signalTf = signalTf;
   alert.biasTf = biasTf;
   alert.price = price;
   alert.bias = biasSnap.swingBias;
   alert.valid = false;
   alert.dir = SMC_DIR_NONE;
   alert.zone = SMC_ZONE_NONE;
   alert.pd = SMC_PD_NONE;
   alert.zoneTime = 0;
   alert.zoneHigh = 0;
   alert.zoneLow = 0;

   ENUM_SMC_PD pd = SmcPdAt(biasSnap, price);
   if(pd == SMC_PD_NONE || pd == SMC_PD_EQUILIBRIUM)
      return false;

   SSmcBox box;
   ENUM_SMC_ZONE kind;
   if(biasSnap.swingBias == SMC_BULLISH && pd == SMC_PD_DISCOUNT)
     {
      if(!SmcPickZone(sigSnap, cfg, SMC_DIR_BUY, price, box, kind))
         return false;
      alert.valid = true;
      alert.dir = SMC_DIR_BUY;
      alert.zone = kind;
      alert.pd = pd;
      alert.zoneTime = box.t0;
      double top, bot;
      SmcBoxEdges(box, top, bot);
      alert.zoneHigh = top;
      alert.zoneLow = bot;
      return true;
     }
   if(biasSnap.swingBias == SMC_BEARISH && pd == SMC_PD_PREMIUM)
     {
      if(!SmcPickZone(sigSnap, cfg, SMC_DIR_SELL, price, box, kind))
         return false;
      alert.valid = true;
      alert.dir = SMC_DIR_SELL;
      alert.zone = kind;
      alert.pd = pd;
      alert.zoneTime = box.t0;
      double top, bot;
      SmcBoxEdges(box, top, bot);
      alert.zoneHigh = top;
      alert.zoneLow = bot;
      return true;
     }
   return false;
  }

string SmcAlertKey(const SSmcAlert &a)
  {
   int dg = (int)SymbolInfoInteger(a.symbol, SYMBOL_DIGITS);
   return a.symbol + "|" + IntegerToString((int)a.signalTf) + "|" +
          IntegerToString((int)a.dir) + "|" + IntegerToString((int)a.zone) + "|" +
          IntegerToString((long)a.zoneTime) + "|" +
          DoubleToString(a.zoneHigh, dg) + "|" + DoubleToString(a.zoneLow, dg);
  }

#endif
