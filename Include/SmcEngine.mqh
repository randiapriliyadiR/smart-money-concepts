#ifndef SMC_ENGINE_MQH
#define SMC_ENGINE_MQH

#include "SmcTypes.mqh"

class CSmcEngine
  {
private:
   SSmcSettings      m_set;
   SSmcSnapshot      m_snap;

   double            m_shLevel, m_shLast;
   bool              m_shCrossed;
   datetime          m_shTime;
   int               m_shIndex;

   double            m_slLevel, m_slLast;
   bool              m_slCrossed;
   datetime          m_slTime;
   int               m_slIndex;

   double            m_ihLevel, m_ihLast;
   bool              m_ihCrossed;
   datetime          m_ihTime;
   int               m_ihIndex;

   double            m_ilLevel, m_ilLast;
   bool              m_ilCrossed;
   datetime          m_ilTime;
   int               m_ilIndex;

   double            m_ehLevel, m_elLevel;
   datetime          m_ehTime, m_elTime;

   int               m_swingBias, m_internalBias;
   int               m_swingLeg, m_internalLeg, m_eqLeg;

   double            m_trailTop, m_trailBottom;
   datetime          m_trailBarTime, m_trailTopTime, m_trailBotTime;
   int               m_trailBarIndex;

   int               m_structHead, m_eqHead, m_swingLblHead;
   int               m_iObHead, m_sObHead, m_fvgHead;
   double            m_fvgCumAbs;

   SSmcBox           m_iOb[SMC_OB_POOL];
   SSmcBox           m_sOb[SMC_OB_POOL];
   SSmcBox           m_fvg[SMC_FVG_POOL];
   SSmcStructEvent   m_structs[SMC_STRUCT_POOL];
   SSmcEqEvent       m_eqhl[SMC_EQHL_POOL];
   SSmcSwingLbl      m_swingLbls[SMC_SWING_LBL_POOL];

   double            m_parsedHigh[];
   double            m_parsedLow[];
   double            m_trCum;

   void              ResetState(void);
   double            HighestAt(const MqlRates &r[], const int i, const int length);
   double            LowestAt(const MqlRates &r[], const int i, const int length);
   double            TrueRange(const MqlRates &r[], const int i);
   void              StoreOb(const int pivotAbs, const int nowAbs, const int bias, const bool internal,
                             const datetime &times[]);
   void              MitigateOb(const bool internal, const bool useClose, const double high, const double low, const double close);
   void              DrawStruct(const double level, const datetime t0, const datetime t1,
                                const ENUM_SMC_TAG tag, const int bias, const bool dashed);
   void              DrawEq(const ENUM_SMC_TAG tag, const datetime t0, const double p0,
                            const datetime t1, const double p1, const int bias);
   void              DrawSwingPt(const ENUM_SMC_TAG tag, const datetime t0, const double price, const int bias, const bool below);
   void              DetectFvgBar(const MqlRates &r[], const int i, const bool newTf);
   void              MitigateFvg(const double high, const double low);
   void              FillZones(void);
   void              CopyBoxesToSnap(void);

public:
                     CSmcEngine(void);
   void              Init(const SSmcSettings &settings);
   void              SetSettings(const SSmcSettings &settings);
   SSmcSettings      Settings(void) const { return m_set; }
   bool              Process(const MqlRates &rates[]);
   bool              Process(const MqlRates &rates[], const MqlRates &fvgRates[]);
   void              SetPrevPeriodLevels(const double pdh, const double pdl, const datetime pdTime,
                                         const double pwh, const double pwl, const datetime pwTime,
                                         const double pmh, const double pml, const datetime pmTime);
   void              GetSnapshot(SSmcSnapshot &out) const;
   int               SwingBias(void) const { return m_swingBias; }
   double            TrailTop(void) const { return m_trailTop; }
   double            TrailBottom(void) const { return m_trailBottom; }
  };

CSmcEngine::CSmcEngine(void)
  {
   SmcSettingsDefault(m_set);
   ResetState();
  }

void CSmcEngine::Init(const SSmcSettings &settings)
  {
   m_set = settings;
   if(m_set.calcBars < 100)
      m_set.calcBars = 100;
   if(m_set.calcBars > SMC_MAX_BARS)
      m_set.calcBars = SMC_MAX_BARS;
   if(m_set.maxStructure < 1)
      m_set.maxStructure = 1;
   if(m_set.maxStructure > SMC_STRUCT_POOL)
      m_set.maxStructure = SMC_STRUCT_POOL;
   ResetState();
  }

void CSmcEngine::SetSettings(const SSmcSettings &settings)
  {
   Init(settings);
  }

void CSmcEngine::ResetState(void)
  {
   m_shLevel = EMPTY_VALUE;
   m_shLast = EMPTY_VALUE;
   m_shCrossed = false;
   m_shTime = 0;
   m_shIndex = 0;
   m_slLevel = EMPTY_VALUE;
   m_slLast = EMPTY_VALUE;
   m_slCrossed = false;
   m_slTime = 0;
   m_slIndex = 0;
   m_ihLevel = EMPTY_VALUE;
   m_ihLast = EMPTY_VALUE;
   m_ihCrossed = false;
   m_ihTime = 0;
   m_ihIndex = 0;
   m_ilLevel = EMPTY_VALUE;
   m_ilLast = EMPTY_VALUE;
   m_ilCrossed = false;
   m_ilTime = 0;
   m_ilIndex = 0;
   m_ehLevel = EMPTY_VALUE;
   m_elLevel = EMPTY_VALUE;
   m_ehTime = 0;
   m_elTime = 0;
   m_swingBias = 0;
   m_internalBias = 0;
   m_swingLeg = 0;
   m_internalLeg = 0;
   m_eqLeg = 0;
   m_trailTop = EMPTY_VALUE;
   m_trailBottom = EMPTY_VALUE;
   m_trailBarTime = 0;
   m_trailTopTime = 0;
   m_trailBotTime = 0;
   m_trailBarIndex = 0;
   m_structHead = 0;
   m_eqHead = 0;
   m_swingLblHead = 0;
   m_iObHead = 0;
   m_sObHead = 0;
   m_fvgHead = 0;
   m_fvgCumAbs = 0.0;
   m_trCum = 0.0;
   ZeroMemory(m_iOb);
   ZeroMemory(m_sOb);
   ZeroMemory(m_fvg);
   ZeroMemory(m_structs);
   ZeroMemory(m_eqhl);
   ZeroMemory(m_swingLbls);
   SmcSnapshotClear(m_snap);
   ArrayResize(m_parsedHigh, 0);
   ArrayResize(m_parsedLow, 0);
  }

double CSmcEngine::HighestAt(const MqlRates &r[], const int i, const int length)
  {
   if(length <= 0 || i < 0)
      return EMPTY_VALUE;
   int from = i - length + 1;
   if(from < 0)
      return EMPTY_VALUE;
   double mx = r[from].high;
   for(int k = from + 1; k <= i; k++)
      if(r[k].high > mx)
         mx = r[k].high;
   return mx;
  }

double CSmcEngine::LowestAt(const MqlRates &r[], const int i, const int length)
  {
   if(length <= 0 || i < 0)
      return EMPTY_VALUE;
   int from = i - length + 1;
   if(from < 0)
      return EMPTY_VALUE;
   double mn = r[from].low;
   for(int k = from + 1; k <= i; k++)
      if(r[k].low < mn)
         mn = r[k].low;
   return mn;
  }

double CSmcEngine::TrueRange(const MqlRates &r[], const int i)
  {
   double hl = r[i].high - r[i].low;
   if(i <= 0)
      return hl;
   double hc = MathAbs(r[i].high - r[i - 1].close);
   double lc = MathAbs(r[i].low - r[i - 1].close);
   return MathMax(hl, MathMax(hc, lc));
  }

void CSmcEngine::DrawStruct(const double level, const datetime t0, const datetime t1,
                            const ENUM_SMC_TAG tag, const int bias, const bool dashed)
  {
   int pool = m_set.maxStructure;
   if(pool > SMC_STRUCT_POOL)
      pool = SMC_STRUCT_POOL;
   if(pool < 1)
      pool = 1;
   int slot = m_structHead % pool;
   m_structs[slot].filled = true;
   m_structs[slot].dashed = dashed;
   m_structs[slot].bias = bias;
   m_structs[slot].tag = tag;
   m_structs[slot].t0 = t0;
   m_structs[slot].t1 = t1;
   m_structs[slot].level = level;
   m_structHead++;
  }

void CSmcEngine::DrawEq(const ENUM_SMC_TAG tag, const datetime t0, const double p0,
                        const datetime t1, const double p1, const int bias)
  {
   int slot = m_eqHead % SMC_EQHL_POOL;
   m_eqhl[slot].filled = true;
   m_eqhl[slot].bias = bias;
   m_eqhl[slot].tag = tag;
   m_eqhl[slot].t0 = t0;
   m_eqhl[slot].t1 = t1;
   m_eqhl[slot].p0 = p0;
   m_eqhl[slot].p1 = p1;
   m_eqHead++;
  }

void CSmcEngine::DrawSwingPt(const ENUM_SMC_TAG tag, const datetime t0, const double price, const int bias, const bool below)
  {
   int slot = m_swingLblHead % SMC_SWING_LBL_POOL;
   m_swingLbls[slot].filled = true;
   m_swingLbls[slot].below = below;
   m_swingLbls[slot].bias = bias;
   m_swingLbls[slot].tag = tag;
   m_swingLbls[slot].t0 = t0;
   m_swingLbls[slot].price = price;
   m_swingLblHead++;
  }

void CSmcEngine::StoreOb(const int pivotAbs, const int nowAbs, const int bias, const bool internal,
                         const datetime &times[])
  {
   if(pivotAbs < 0 || pivotAbs > nowAbs)
      return;
   int offsetStart = nowAbs - pivotAbs;
   if(offsetStart < 0)
      return;
   if(offsetStart > SMC_OB_LOOKBACK)
      offsetStart = SMC_OB_LOOKBACK;
   int bestOffset = 0;
   if(bias == SMC_BEARISH)
     {
      double bestVal = m_parsedHigh[nowAbs];
      for(int off = 0; off <= offsetStart; off++)
        {
         int idx = nowAbs - off;
         if(idx < 0)
            break;
         double v = m_parsedHigh[idx];
         if(SmcValid(v) && (!SmcValid(bestVal) || v >= bestVal))
           {
            bestVal = v;
            bestOffset = off;
           }
        }
     }
   else
     {
      double bestVal = m_parsedLow[nowAbs];
      for(int off = 0; off <= offsetStart; off++)
        {
         int idx = nowAbs - off;
         if(idx < 0)
            break;
         double v = m_parsedLow[idx];
         if(SmcValid(v) && (!SmcValid(bestVal) || v <= bestVal))
           {
            bestVal = v;
            bestOffset = off;
           }
        }
     }
   int idx = nowAbs - bestOffset;
   if(idx < 0)
      return;
   double obHigh = m_parsedHigh[idx];
   double obLow = m_parsedLow[idx];
   if(!SmcValid(obHigh) || !SmcValid(obLow))
      return;
   datetime obTime = times[idx];
   if(internal)
     {
      int slot = m_iObHead % SMC_OB_POOL;
      m_iOb[slot].active = true;
      m_iOb[slot].bias = bias;
      m_iOb[slot].t0 = obTime;
      m_iOb[slot].t1 = times[nowAbs];
      m_iOb[slot].high = obHigh;
      m_iOb[slot].low = obLow;
      m_iObHead++;
     }
   else
     {
      int slot = m_sObHead % SMC_OB_POOL;
      m_sOb[slot].active = true;
      m_sOb[slot].bias = bias;
      m_sOb[slot].t0 = obTime;
      m_sOb[slot].t1 = times[nowAbs];
      m_sOb[slot].high = obHigh;
      m_sOb[slot].low = obLow;
      m_sObHead++;
     }
  }

void CSmcEngine::MitigateOb(const bool internal, const bool useClose, const double high, const double low, const double close)
  {
   double bearSrc = useClose ? close : high;
   double bullSrc = useClose ? close : low;
   if(internal)
     {
      for(int i = 0; i < SMC_OB_POOL; i++)
        {
         if(!m_iOb[i].active)
            continue;
         if(m_iOb[i].bias == SMC_BEARISH && bearSrc > m_iOb[i].high)
            m_iOb[i].active = false;
         if(m_iOb[i].bias == SMC_BULLISH && bullSrc < m_iOb[i].low)
            m_iOb[i].active = false;
        }
     }
   else
     {
      for(int i = 0; i < SMC_OB_POOL; i++)
        {
         if(!m_sOb[i].active)
            continue;
         if(m_sOb[i].bias == SMC_BEARISH && bearSrc > m_sOb[i].high)
            m_sOb[i].active = false;
         if(m_sOb[i].bias == SMC_BULLISH && bullSrc < m_sOb[i].low)
            m_sOb[i].active = false;
        }
     }
  }

void CSmcEngine::MitigateFvg(const double high, const double low)
  {
   for(int i = 0; i < SMC_FVG_POOL; i++)
     {
      if(!m_fvg[i].active)
         continue;
      if(m_fvg[i].bias == SMC_BULLISH && low < m_fvg[i].low)
         m_fvg[i].active = false;
      if(m_fvg[i].bias == SMC_BEARISH && high > m_fvg[i].high)
         m_fvg[i].active = false;
     }
  }

void CSmcEngine::DetectFvgBar(const MqlRates &r[], const int i, const bool newTf)
  {
   if(!newTf || i < 2)
      return;
   double lastClose = r[i - 1].close;
   double lastOpen = r[i - 1].open;
   datetime lastTime = r[i - 1].time;
   double curHigh = r[i].high;
   double curLow = r[i].low;
   datetime curTime = r[i].time;
   double last2High = r[i - 2].high;
   double last2Low = r[i - 2].low;
   double barDeltaPct = 0.0;
   if(lastOpen != 0.0)
      barDeltaPct = (lastClose - lastOpen) / (lastOpen * 100.0);
   if(newTf)
      m_fvgCumAbs += MathAbs(barDeltaPct);
   double threshold = 0.0;
   if(m_set.fvgAutoThreshold && i > 0)
      threshold = (m_fvgCumAbs / (double)i) * 2.0;
   int dur = 60;
   if(i > 0)
     {
      int d = (int)(r[i].time - r[i - 1].time);
      if(d > 0)
         dur = d;
     }
   datetime rightT = curTime + (datetime)(m_set.fvgExtend * dur);
   bool bull = (curLow > last2High && lastClose > last2High && barDeltaPct > threshold);
   bool bear = (curHigh < last2Low && lastClose < last2Low && (-barDeltaPct) > threshold);
   if(bull)
     {
      int slot = m_fvgHead % SMC_FVG_POOL;
      m_fvg[slot].active = true;
      m_fvg[slot].bias = SMC_BULLISH;
      m_fvg[slot].t0 = lastTime;
      m_fvg[slot].t1 = rightT;
      m_fvg[slot].high = curLow;
      m_fvg[slot].low = last2High;
      m_fvgHead++;
     }
   if(bear)
     {
      int slot = m_fvgHead % SMC_FVG_POOL;
      m_fvg[slot].active = true;
      m_fvg[slot].bias = SMC_BEARISH;
      m_fvg[slot].t0 = lastTime;
      m_fvg[slot].t1 = rightT;
      m_fvg[slot].high = curHigh;
      m_fvg[slot].low = last2Low;
      m_fvgHead++;
     }
  }

void CSmcEngine::FillZones(void)
  {
   if(!SmcValid(m_trailTop) || !SmcValid(m_trailBottom))
      return;
   m_snap.premiumTop = m_trailTop;
   m_snap.premiumBot = 0.95 * m_trailTop + 0.05 * m_trailBottom;
   m_snap.discountBot = m_trailBottom;
   m_snap.discountTop = 0.95 * m_trailBottom + 0.05 * m_trailTop;
   m_snap.eqTop = 0.525 * m_trailTop + 0.475 * m_trailBottom;
   m_snap.eqBot = 0.525 * m_trailBottom + 0.475 * m_trailTop;
  }

void CSmcEngine::CopyBoxesToSnap(void)
  {
   for(int i = 0; i < SMC_OB_POOL; i++)
     {
      m_snap.iOb[i] = m_iOb[i];
      m_snap.sOb[i] = m_sOb[i];
     }
   for(int i = 0; i < SMC_FVG_POOL; i++)
      m_snap.fvg[i] = m_fvg[i];
   int pool = m_set.maxStructure;
   if(pool > SMC_STRUCT_POOL)
      pool = SMC_STRUCT_POOL;
   m_snap.structCount = 0;
   for(int i = 0; i < pool; i++)
     {
      m_snap.structs[i] = m_structs[i];
      if(m_structs[i].filled)
         m_snap.structCount++;
     }
   m_snap.eqCount = 0;
   for(int i = 0; i < SMC_EQHL_POOL; i++)
     {
      m_snap.eqhl[i] = m_eqhl[i];
      if(m_eqhl[i].filled)
         m_snap.eqCount++;
     }
   m_snap.swingLblCount = 0;
   for(int i = 0; i < SMC_SWING_LBL_POOL; i++)
     {
      m_snap.swingLbls[i] = m_swingLbls[i];
      if(m_swingLbls[i].filled)
         m_snap.swingLblCount++;
     }
  }

void CSmcEngine::SetPrevPeriodLevels(const double pdh, const double pdl, const datetime pdTime,
                                     const double pwh, const double pwl, const datetime pwTime,
                                     const double pmh, const double pml, const datetime pmTime)
  {
   m_snap.pdh = pdh;
   m_snap.pdl = pdl;
   m_snap.pdTime = pdTime;
   m_snap.pwh = pwh;
   m_snap.pwl = pwl;
   m_snap.pwTime = pwTime;
   m_snap.pmh = pmh;
   m_snap.pml = pml;
   m_snap.pmTime = pmTime;
  }

void CSmcEngine::GetSnapshot(SSmcSnapshot &out) const
  {
   out = m_snap;
  }

bool CSmcEngine::Process(const MqlRates &rates[])
  {
   MqlRates dummy[];
   ArrayResize(dummy, 0);
   return Process(rates, dummy);
  }

bool CSmcEngine::Process(const MqlRates &ratesIn[], const MqlRates &fvgRatesIn[])
  {
   int nAll = ArraySize(ratesIn);
   if(nAll < 3)
      return false;

   MqlRates rates[];
   ArrayResize(rates, nAll);
   ArrayCopy(rates, ratesIn);
   ArraySetAsSeries(rates, false);
   if(ArraySize(rates) > 1 && rates[0].time > rates[ArraySize(rates) - 1].time)
     {
      ArraySetAsSeries(rates, true);
      ArraySetAsSeries(rates, false);
     }
   // Ensure oldest-first
   if(ArraySize(rates) > 1 && rates[0].time > rates[ArraySize(rates) - 1].time)
     {
      int nn = ArraySize(rates);
      for(int a = 0; a < nn / 2; a++)
        {
         MqlRates tmp = rates[a];
         rates[a] = rates[nn - 1 - a];
         rates[nn - 1 - a] = tmp;
        }
     }

   int n = ArraySize(rates);
   int use = n;
   if(use > m_set.calcBars)
      use = m_set.calcBars;
   int start = n - use;
   if(start < 0)
      start = 0;

   ResetState();
   ArrayResize(m_parsedHigh, n);
   ArrayResize(m_parsedLow, n);
   ArrayInitialize(m_parsedHigh, EMPTY_VALUE);
   ArrayInitialize(m_parsedLow, EMPTY_VALUE);

   datetime times[];
   ArrayResize(times, n);
   for(int t = 0; t < n; t++)
      times[t] = rates[t].time;

   bool needOb = m_set.showInternalOb || m_set.showSwingOb;
   bool needSwing = m_set.showSwing || m_set.showSwingOb || m_set.showStrongWeak || m_set.showZones;
   bool needInternal = m_set.showInternal || m_set.showInternalOb;
   bool needAtr = m_set.showEqhl || needOb;
   bool useCloseMit = (m_set.obMitigation == SMC_OB_MIT_CLOSE);

   MqlRates fvgR[];
   bool fvgSeparate = (ArraySize(fvgRatesIn) > 3);
   if(fvgSeparate)
     {
      int fn = ArraySize(fvgRatesIn);
      ArrayResize(fvgR, fn);
      ArrayCopy(fvgR, fvgRatesIn);
      if(fn > 1 && fvgR[0].time > fvgR[fn - 1].time)
        {
         for(int a = 0; a < fn / 2; a++)
           {
            MqlRates tmp = fvgR[a];
            fvgR[a] = fvgR[fn - 1 - a];
            fvgR[fn - 1 - a] = tmp;
           }
        }
     }

   double atr = EMPTY_VALUE;
   double atrSma = 0.0;
   int atrCount = 0;

   for(int i = start; i < n; i++)
     {
      int barIndex = i - start;
      double tr = TrueRange(rates, i);
      m_trCum += tr;
      if(needAtr)
        {
         if(atrCount < SMC_ATR_LEN)
           {
            atrSma += tr;
            atrCount++;
            if(atrCount == SMC_ATR_LEN)
               atr = atrSma / (double)SMC_ATR_LEN;
           }
         else if(SmcValid(atr))
            atr = (atr * (SMC_ATR_LEN - 1) + tr) / (double)SMC_ATR_LEN;
        }

      double parsedH = rates[i].high;
      double parsedL = rates[i].low;
      if(needOb)
        {
         double volatility = atr;
         if(m_set.obFilter != SMC_OB_ATR)
           {
            if(barIndex > 0)
               volatility = m_trCum / (double)barIndex;
           }
         bool highVol = false;
         if(SmcValid(volatility))
            highVol = ((rates[i].high - rates[i].low) >= (2.0 * volatility));
         if(highVol)
           {
            parsedH = rates[i].low;
            parsedL = rates[i].high;
           }
        }
      m_parsedHigh[i] = parsedH;
      m_parsedLow[i] = parsedL;

      if(needSwing)
        {
         int slen = m_set.swingsLength;
         double swingHi = HighestAt(rates, i, slen);
         double swingLo = LowestAt(rates, i, slen);
         if(barIndex >= slen && SmcValid(swingHi) && SmcValid(swingLo) && (i - slen) >= 0)
           {
            int newLeg = m_swingLeg;
            if(rates[i - slen].high > swingHi)
               newLeg = SMC_BEARISH_LEG;
            else if(rates[i - slen].low < swingLo)
               newLeg = SMC_BULLISH_LEG;
            bool changed = (newLeg != m_swingLeg);
            bool pl = changed && newLeg == SMC_BULLISH_LEG;
            bool ph = changed && newLeg == SMC_BEARISH_LEG;
            m_swingLeg = newLeg;
            if(pl)
              {
               double lvl = rates[i - slen].low;
               if(m_set.showSwingPoints && SmcValid(m_slLevel))
                 {
                  ENUM_SMC_TAG tag = (lvl < m_slLevel) ? SMC_TAG_LL : SMC_TAG_HL;
                  DrawSwingPt(tag, rates[i - slen].time, lvl, SMC_BULLISH, false);
                 }
               m_slLast = m_slLevel;
               m_slLevel = lvl;
               m_slCrossed = false;
               m_slTime = rates[i - slen].time;
               m_slIndex = i - slen;
               m_trailBottom = lvl;
               m_trailBarTime = m_slTime;
               m_trailBarIndex = m_slIndex;
               m_trailBotTime = m_slTime;
              }
            else if(ph)
              {
               double lvl = rates[i - slen].high;
               if(m_set.showSwingPoints && SmcValid(m_shLevel))
                 {
                  ENUM_SMC_TAG tag = (lvl > m_shLevel) ? SMC_TAG_HH : SMC_TAG_LH;
                  DrawSwingPt(tag, rates[i - slen].time, lvl, SMC_BEARISH, true);
                 }
               m_shLast = m_shLevel;
               m_shLevel = lvl;
               m_shCrossed = false;
               m_shTime = rates[i - slen].time;
               m_shIndex = i - slen;
               m_trailTop = lvl;
               m_trailBarTime = m_shTime;
               m_trailBarIndex = m_shIndex;
               m_trailTopTime = m_shTime;
              }
           }
        }

      if(needInternal)
        {
         int ilen = SMC_INTERNAL_LEN;
         double intHi = HighestAt(rates, i, ilen);
         double intLo = LowestAt(rates, i, ilen);
         if(barIndex >= ilen && SmcValid(intHi) && SmcValid(intLo) && (i - ilen) >= 0)
           {
            int newLeg = m_internalLeg;
            if(rates[i - ilen].high > intHi)
               newLeg = SMC_BEARISH_LEG;
            else if(rates[i - ilen].low < intLo)
               newLeg = SMC_BULLISH_LEG;
            bool changed = (newLeg != m_internalLeg);
            m_internalLeg = newLeg;
            if(changed && newLeg == SMC_BULLISH_LEG)
              {
               m_ilLast = m_ilLevel;
               m_ilLevel = rates[i - ilen].low;
               m_ilCrossed = false;
               m_ilTime = rates[i - ilen].time;
               m_ilIndex = i - ilen;
              }
            else if(changed && newLeg == SMC_BEARISH_LEG)
              {
               m_ihLast = m_ihLevel;
               m_ihLevel = rates[i - ilen].high;
               m_ihCrossed = false;
               m_ihTime = rates[i - ilen].time;
               m_ihIndex = i - ilen;
              }
           }
        }

      if(m_set.showEqhl)
        {
         int elen = m_set.eqhlLength;
         double eqHi = HighestAt(rates, i, elen);
         double eqLo = LowestAt(rates, i, elen);
         if(barIndex >= elen && SmcValid(eqHi) && SmcValid(eqLo) && (i - elen) >= 0)
           {
            int newLeg = m_eqLeg;
            if(rates[i - elen].high > eqHi)
               newLeg = SMC_BEARISH_LEG;
            else if(rates[i - elen].low < eqLo)
               newLeg = SMC_BULLISH_LEG;
            bool changed = (newLeg != m_eqLeg);
            m_eqLeg = newLeg;
            if(changed && newLeg == SMC_BULLISH_LEG)
              {
               double lvl = rates[i - elen].low;
               if(SmcValid(m_elLevel) && SmcValid(atr) && MathAbs(m_elLevel - lvl) < m_set.eqhlThreshold * atr)
                  DrawEq(SMC_TAG_EQL, m_elTime, m_elLevel, rates[i - elen].time, lvl, SMC_BULLISH);
               m_elLevel = lvl;
               m_elTime = rates[i - elen].time;
              }
            else if(changed && newLeg == SMC_BEARISH_LEG)
              {
               double lvl = rates[i - elen].high;
               if(SmcValid(m_ehLevel) && SmcValid(atr) && MathAbs(m_ehLevel - lvl) < m_set.eqhlThreshold * atr)
                  DrawEq(SMC_TAG_EQH, m_ehTime, m_ehLevel, rates[i - elen].time, lvl, SMC_BEARISH);
               m_ehLevel = lvl;
               m_ehTime = rates[i - elen].time;
              }
           }
        }

      bool bullishBar = true;
      bool bearishBar = true;
      if(m_set.internalConfluence)
        {
         double upper = rates[i].high - MathMax(rates[i].close, rates[i].open);
         double lowerCmp = MathMin(rates[i].close, rates[i].open - rates[i].low);
         bullishBar = (upper > lowerCmp);
         bearishBar = (upper < lowerCmp);
        }

      if((m_set.showInternal || m_set.showInternalOb) && i > start)
        {
         if(SmcValid(m_ihLevel) && !m_ihCrossed &&
            rates[i - 1].close <= m_ihLevel && rates[i].close > m_ihLevel &&
            m_ihLevel != m_shLevel && bullishBar)
           {
            ENUM_SMC_TAG tag = (m_internalBias == SMC_BEARISH) ? SMC_TAG_CHOCH : SMC_TAG_BOS;
            m_ihCrossed = true;
            m_internalBias = SMC_BULLISH;
            if(m_set.showInternal && SmcTagAllowed(m_set.internalBull, tag))
               DrawStruct(m_ihLevel, m_ihTime, rates[i].time, tag, SMC_BULLISH, true);
            if(m_set.showInternalOb)
               StoreOb(m_ihIndex, i, SMC_BULLISH, true, times);
           }
         if(SmcValid(m_ilLevel) && !m_ilCrossed &&
            rates[i - 1].close >= m_ilLevel && rates[i].close < m_ilLevel &&
            m_ilLevel != m_slLevel && bearishBar)
           {
            ENUM_SMC_TAG tag = (m_internalBias == SMC_BULLISH) ? SMC_TAG_CHOCH : SMC_TAG_BOS;
            m_ilCrossed = true;
            m_internalBias = SMC_BEARISH;
            if(m_set.showInternal && SmcTagAllowed(m_set.internalBear, tag))
               DrawStruct(m_ilLevel, m_ilTime, rates[i].time, tag, SMC_BEARISH, true);
            if(m_set.showInternalOb)
               StoreOb(m_ilIndex, i, SMC_BEARISH, true, times);
           }
        }

      if(m_set.showSwing || m_set.showSwingOb || m_set.showStrongWeak)
        {
         if(i > start)
           {
            if(SmcValid(m_shLevel) && !m_shCrossed &&
               rates[i - 1].close <= m_shLevel && rates[i].close > m_shLevel)
              {
               ENUM_SMC_TAG tag = (m_swingBias == SMC_BEARISH) ? SMC_TAG_CHOCH : SMC_TAG_BOS;
               m_shCrossed = true;
               m_swingBias = SMC_BULLISH;
               if(m_set.showSwing && SmcTagAllowed(m_set.swingBull, tag))
                  DrawStruct(m_shLevel, m_shTime, rates[i].time, tag, SMC_BULLISH, false);
               if(m_set.showSwingOb)
                  StoreOb(m_shIndex, i, SMC_BULLISH, false, times);
              }
            if(SmcValid(m_slLevel) && !m_slCrossed &&
               rates[i - 1].close >= m_slLevel && rates[i].close < m_slLevel)
              {
               ENUM_SMC_TAG tag = (m_swingBias == SMC_BULLISH) ? SMC_TAG_CHOCH : SMC_TAG_BOS;
               m_slCrossed = true;
               m_swingBias = SMC_BEARISH;
               if(m_set.showSwing && SmcTagAllowed(m_set.swingBear, tag))
                  DrawStruct(m_slLevel, m_slTime, rates[i].time, tag, SMC_BEARISH, false);
               if(m_set.showSwingOb)
                  StoreOb(m_slIndex, i, SMC_BEARISH, false, times);
              }
           }
        }

      if(m_set.showInternalOb)
         MitigateOb(true, useCloseMit, rates[i].high, rates[i].low, rates[i].close);
      if(m_set.showSwingOb)
         MitigateOb(false, useCloseMit, rates[i].high, rates[i].low, rates[i].close);

      if(m_set.showFvg && !fvgSeparate)
        {
         MitigateFvg(rates[i].high, rates[i].low);
         bool newTf = (i > start);
         DetectFvgBar(rates, i, newTf);
        }
      else if(m_set.showFvg && fvgSeparate)
         MitigateFvg(rates[i].high, rates[i].low);

      if(m_set.showStrongWeak || m_set.showZones)
        {
         if(SmcValid(m_trailTop))
           {
            if(rates[i].high >= m_trailTop)
              {
               m_trailTop = rates[i].high;
               m_trailTopTime = rates[i].time;
              }
           }
         else if(SmcValid(m_shLevel))
           {
            m_trailTop = m_shLevel;
            m_trailTopTime = m_shTime;
           }
         if(SmcValid(m_trailBottom))
           {
            if(rates[i].low <= m_trailBottom)
              {
               m_trailBottom = rates[i].low;
               m_trailBotTime = rates[i].time;
              }
           }
         else if(SmcValid(m_slLevel))
           {
            m_trailBottom = m_slLevel;
            m_trailBotTime = m_slTime;
           }
        }

      for(int b = 0; b < SMC_OB_POOL; b++)
        {
         if(m_iOb[b].active)
            m_iOb[b].t1 = rates[i].time;
         if(m_sOb[b].active)
            m_sOb[b].t1 = rates[i].time;
        }
     }

   if(m_set.showFvg && fvgSeparate)
     {
      int fn = ArraySize(fvgR);
      int fstart = 0;
      if(fn > m_set.calcBars)
         fstart = fn - m_set.calcBars;
      m_fvgCumAbs = 0.0;
      for(int fi = fstart; fi < fn; fi++)
        {
         bool newTf = (fi > fstart);
         DetectFvgBar(fvgR, fi, newTf);
        }
      if(n > 0)
         MitigateFvg(rates[n - 1].high, rates[n - 1].low);
     }

   datetime lastT = (n > 0 ? rates[n - 1].time : 0);
   int poolN = m_set.maxStructure;
   if(poolN > SMC_STRUCT_POOL)
      poolN = SMC_STRUCT_POOL;
   for(int s = 0; s < poolN; s++)
     {
      if(m_structs[s].filled)
         m_structs[s].t1 = lastT;
     }

   m_snap.swingBias = m_swingBias;
   m_snap.internalBias = m_internalBias;
   m_snap.trailTop = m_trailTop;
   m_snap.trailBottom = m_trailBottom;
   m_snap.trailTopTime = m_trailTopTime;
   m_snap.trailBotTime = m_trailBotTime;
   m_snap.trailBarTime = m_trailBarTime;
   FillZones();
   CopyBoxesToSnap();
   return true;
  }

#endif
