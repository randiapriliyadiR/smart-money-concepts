#ifndef SMC_DRAW_MQH
#define SMC_DRAW_MQH

#include "SmcTypes.mqh"

class CSmcDraw
  {
private:
   long              m_chart;
   string            m_prefix;
   int               m_digits;
   color             m_swingBull, m_swingBear, m_intBull, m_intBear;
   color             m_iObBull, m_iObBear, m_sObBull, m_sObBear;
   color             m_fvgBull, m_fvgBear;
   color             m_prem, m_eq, m_disc, m_daily, m_weekly, m_monthly;
   ENUM_SMC_LINE     m_dailyStyle, m_weeklyStyle, m_monthlyStyle;
   int               m_intFont, m_swingFont, m_eqFont;
   int               m_iObCount, m_sObCount;
   bool              m_showInternal, m_showSwing, m_showStrong, m_showIOb, m_showSOb;
   bool              m_showEq, m_showFvg, m_showDaily, m_showWeekly, m_showMonthly, m_showZones;
   bool              m_showSwingPts;
   ENUM_SMC_STYLE    m_style;

   string            Name(const string id) const;
   ENUM_LINE_STYLE   LineStyle(const ENUM_SMC_LINE s) const;
   void              Rect(const string id, datetime t0, datetime t1, double p0, double p1,
                          const color fill, const color border, const bool back);
   void              HLineSeg(const string id, datetime t0, datetime t1, const double price,
                              const color clr, const ENUM_LINE_STYLE st, const int width);
   void              Txt(const string id, datetime t, const double price, const string text,
                         const color clr, const int fontPx, const ENUM_ANCHOR_POINT anchor);

public:
                     CSmcDraw(void);
   void              Configure(const SSmcSettings &set,
                               const color swingBull, const color swingBear,
                               const color intBull, const color intBear,
                               const color iObBull, const color iObBear,
                               const color sObBull, const color sObBear,
                               const color fvgBull, const color fvgBear,
                               const color prem, const color eq, const color disc,
                               const color daily, const color weekly, const color monthly,
                               const ENUM_SMC_LINE dailySt, const ENUM_SMC_LINE weeklySt, const ENUM_SMC_LINE monthlySt,
                               const ENUM_SMC_FONT intFont, const ENUM_SMC_FONT swingFont, const ENUM_SMC_FONT eqFont);
   void              Clear(void);
   void              Render(const SSmcSnapshot &snap, const string symbol);
  };

CSmcDraw::CSmcDraw(void)
  {
   m_chart = 0;
   m_prefix = SMC_OBJ_PREFIX;
   m_digits = _Digits;
   m_swingBull = SMC_CLR_GREEN;
   m_swingBear = SMC_CLR_RED;
   m_intBull = SMC_CLR_GREEN;
   m_intBear = SMC_CLR_RED;
   m_iObBull = SMC_CLR_IOB_BULL;
   m_iObBear = SMC_CLR_IOB_BEAR;
   m_sObBull = SMC_CLR_SOB_BULL;
   m_sObBear = SMC_CLR_SOB_BEAR;
   m_fvgBull = SMC_CLR_FVG_BULL;
   m_fvgBear = SMC_CLR_FVG_BEAR;
   m_prem = SMC_CLR_RED;
   m_eq = SMC_CLR_GRAY;
   m_disc = SMC_CLR_GREEN;
   m_daily = SMC_CLR_BLUE;
   m_weekly = SMC_CLR_BLUE;
   m_monthly = SMC_CLR_BLUE;
   m_dailyStyle = SMC_LINE_SOLID;
   m_weeklyStyle = SMC_LINE_SOLID;
   m_monthlyStyle = SMC_LINE_SOLID;
   m_intFont = 8;
   m_swingFont = 10;
   m_eqFont = 8;
   m_iObCount = 5;
   m_sObCount = 5;
   m_showInternal = true;
   m_showSwing = true;
   m_showStrong = true;
   m_showIOb = true;
   m_showSOb = true;
   m_showEq = true;
   m_showFvg = true;
   m_showDaily = false;
   m_showWeekly = false;
   m_showMonthly = false;
   m_showZones = true;
   m_showSwingPts = false;
   m_style = SMC_STYLE_COLORED;
  }

string CSmcDraw::Name(const string id) const
  {
   return m_prefix + id;
  }

ENUM_LINE_STYLE CSmcDraw::LineStyle(const ENUM_SMC_LINE s) const
  {
   if(s == SMC_LINE_DASHED)
      return STYLE_DASH;
   if(s == SMC_LINE_DOTTED)
      return STYLE_DOT;
   return STYLE_SOLID;
  }

void CSmcDraw::Configure(const SSmcSettings &set,
                         const color swingBull, const color swingBear,
                         const color intBull, const color intBear,
                         const color iObBull, const color iObBear,
                         const color sObBull, const color sObBear,
                         const color fvgBull, const color fvgBear,
                         const color prem, const color eq, const color disc,
                         const color daily, const color weekly, const color monthly,
                         const ENUM_SMC_LINE dailySt, const ENUM_SMC_LINE weeklySt, const ENUM_SMC_LINE monthlySt,
                         const ENUM_SMC_FONT intFont, const ENUM_SMC_FONT swingFont, const ENUM_SMC_FONT eqFont)
  {
   m_chart = ChartID();
   m_style = set.style;
   m_showInternal = set.showInternal;
   m_showSwing = set.showSwing;
   m_showSwingPts = set.showSwingPoints;
   m_showStrong = set.showStrongWeak;
   m_showIOb = set.showInternalOb;
   m_showSOb = set.showSwingOb;
   m_showEq = set.showEqhl;
   m_showFvg = set.showFvg;
   m_showDaily = set.showDaily;
   m_showWeekly = set.showWeekly;
   m_showMonthly = set.showMonthly;
   m_showZones = set.showZones;
   m_iObCount = set.internalObCount;
   m_sObCount = set.swingObCount;
   m_intFont = SmcFontPx(intFont);
   m_swingFont = SmcFontPx(swingFont);
   m_eqFont = SmcFontPx(eqFont);
   if(m_style == SMC_STYLE_MONO)
     {
      m_swingBull = SMC_CLR_MONO_BULL;
      m_swingBear = SMC_CLR_MONO_BEAR;
      m_intBull = SMC_CLR_MONO_BULL;
      m_intBear = SMC_CLR_MONO_BEAR;
      m_iObBull = SMC_CLR_MONO_BULL;
      m_iObBear = SMC_CLR_MONO_BEAR;
      m_sObBull = SMC_CLR_MONO_BULL;
      m_sObBear = SMC_CLR_MONO_BEAR;
      m_fvgBull = SMC_CLR_MONO_BULL;
      m_fvgBear = SMC_CLR_MONO_BEAR;
      m_prem = SMC_CLR_MONO_BEAR;
      m_disc = SMC_CLR_MONO_BULL;
      m_eq = eq;
     }
   else
     {
      m_swingBull = swingBull;
      m_swingBear = swingBear;
      m_intBull = intBull;
      m_intBear = intBear;
      m_iObBull = iObBull;
      m_iObBear = iObBear;
      m_sObBull = sObBull;
      m_sObBear = sObBear;
      m_fvgBull = fvgBull;
      m_fvgBear = fvgBear;
      m_prem = prem;
      m_eq = eq;
      m_disc = disc;
     }
   m_daily = daily;
   m_weekly = weekly;
   m_monthly = monthly;
   m_dailyStyle = dailySt;
   m_weeklyStyle = weeklySt;
   m_monthlyStyle = monthlySt;
  }

void CSmcDraw::Clear(void)
  {
   ObjectsDeleteAll(m_chart, m_prefix);
  }

void CSmcDraw::Rect(const string id, datetime t0, datetime t1, double p0, double p1,
                    const color fill, const color border, const bool back)
  {
   string n = Name(id);
   if(t1 <= t0)
      t1 = t0 + PeriodSeconds();
   if(ObjectFind(m_chart, n) < 0)
     {
      ObjectCreate(m_chart, n, OBJ_RECTANGLE, 0, t0, p0, t1, p1);
     }
   ObjectSetInteger(m_chart, n, OBJPROP_TIME, 0, t0);
   ObjectSetDouble(m_chart, n, OBJPROP_PRICE, 0, p0);
   ObjectSetInteger(m_chart, n, OBJPROP_TIME, 1, t1);
   ObjectSetDouble(m_chart, n, OBJPROP_PRICE, 1, p1);
   ObjectSetInteger(m_chart, n, OBJPROP_COLOR, border);
   ObjectSetInteger(m_chart, n, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(m_chart, n, OBJPROP_WIDTH, 1);
   ObjectSetInteger(m_chart, n, OBJPROP_FILL, true);
   ObjectSetInteger(m_chart, n, OBJPROP_BACK, back);
   ObjectSetInteger(m_chart, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(m_chart, n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(m_chart, n, OBJPROP_BGCOLOR, fill);
  }

void CSmcDraw::HLineSeg(const string id, datetime t0, datetime t1, const double price,
                        const color clr, const ENUM_LINE_STYLE st, const int width)
  {
   string n = Name(id);
   if(t1 <= t0)
      t1 = t0 + PeriodSeconds();
   if(ObjectFind(m_chart, n) < 0)
      ObjectCreate(m_chart, n, OBJ_TREND, 0, t0, price, t1, price);
   ObjectSetInteger(m_chart, n, OBJPROP_TIME, 0, t0);
   ObjectSetDouble(m_chart, n, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(m_chart, n, OBJPROP_TIME, 1, t1);
   ObjectSetDouble(m_chart, n, OBJPROP_PRICE, 1, price);
   ObjectSetInteger(m_chart, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(m_chart, n, OBJPROP_STYLE, st);
   ObjectSetInteger(m_chart, n, OBJPROP_WIDTH, width);
   ObjectSetInteger(m_chart, n, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(m_chart, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(m_chart, n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(m_chart, n, OBJPROP_BACK, false);
  }

void CSmcDraw::Txt(const string id, datetime t, const double price, const string text,
                   const color clr, const int fontPx, const ENUM_ANCHOR_POINT anchor)
  {
   string n = Name(id);
   if(ObjectFind(m_chart, n) < 0)
      ObjectCreate(m_chart, n, OBJ_TEXT, 0, t, price);
   ObjectSetInteger(m_chart, n, OBJPROP_TIME, t);
   ObjectSetDouble(m_chart, n, OBJPROP_PRICE, price);
   ObjectSetString(m_chart, n, OBJPROP_TEXT, text);
   ObjectSetString(m_chart, n, OBJPROP_FONT, "Arial");
   ObjectSetInteger(m_chart, n, OBJPROP_FONTSIZE, fontPx);
   ObjectSetInteger(m_chart, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(m_chart, n, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(m_chart, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(m_chart, n, OBJPROP_HIDDEN, true);
  }

void CSmcDraw::Render(const SSmcSnapshot &snap, const string symbol)
  {
   m_chart = ChartID();
   m_digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   datetime now = TimeCurrent();
   datetime ext = now + (datetime)(SMC_LINE_EXTEND_BARS * PeriodSeconds());

   color iBull = m_intBull;
   color iBear = m_intBear;
   color sBull = m_swingBull;
   color sBear = m_swingBear;

   if(m_showInternal || m_showSwing)
     {
      for(int i = 0; i < SMC_STRUCT_POOL; i++)
        {
         if(!snap.structs[i].filled)
            continue;
         bool dashed = snap.structs[i].dashed;
         if(dashed && !m_showInternal)
            continue;
         if(!dashed && !m_showSwing)
            continue;
         color c = (snap.structs[i].bias == SMC_BULLISH) ? (dashed ? iBull : sBull)
                                                         : (dashed ? iBear : sBear);
         string id = "st" + IntegerToString(i);
         HLineSeg(id, snap.structs[i].t0, snap.structs[i].t1, snap.structs[i].level,
                  c, dashed ? STYLE_DASH : STYLE_SOLID, 1);
         datetime mid = snap.structs[i].t0 + (snap.structs[i].t1 - snap.structs[i].t0) / 2;
         Txt(id + "l", mid, snap.structs[i].level, SmcTagText(snap.structs[i].tag),
             c, dashed ? m_intFont : m_swingFont, ANCHOR_LEFT);
        }
     }

   if(m_showEq)
     {
      for(int i = 0; i < SMC_EQHL_POOL; i++)
        {
         if(!snap.eqhl[i].filled)
            continue;
         color c = (snap.eqhl[i].bias == SMC_BULLISH) ? sBull : sBear;
         string id = "eq" + IntegerToString(i);
         HLineSeg(id, snap.eqhl[i].t0, snap.eqhl[i].t1, snap.eqhl[i].p1, c, STYLE_DOT, 1);
         datetime mid = snap.eqhl[i].t0 + (snap.eqhl[i].t1 - snap.eqhl[i].t0) / 2;
         Txt(id + "l", mid, snap.eqhl[i].p1, SmcTagText(snap.eqhl[i].tag), c, m_eqFont, ANCHOR_LEFT);
        }
     }

   if(m_showSwingPts)
     {
      for(int i = 0; i < SMC_SWING_LBL_POOL; i++)
        {
         if(!snap.swingLbls[i].filled)
            continue;
         color c = (snap.swingLbls[i].bias == SMC_BULLISH) ? sBull : sBear;
         Txt("sp" + IntegerToString(i), snap.swingLbls[i].t0, snap.swingLbls[i].price,
             SmcTagText(snap.swingLbls[i].tag), c, m_swingFont,
             snap.swingLbls[i].below ? ANCHOR_UPPER : ANCHOR_LOWER);
        }
     }

   if(m_showIOb)
     {
      int drawn = 0;
      for(int k = 0; k < SMC_OB_POOL && drawn < m_iObCount; k++)
        {
         if(!snap.iOb[k].active)
            continue;
         color c = (snap.iOb[k].bias == SMC_BULLISH) ? m_iObBull : m_iObBear;
         Rect("iob" + IntegerToString(k), snap.iOb[k].t0, snap.iOb[k].t1,
              snap.iOb[k].high, snap.iOb[k].low, c, c, true);
         drawn++;
        }
     }
   if(m_showSOb)
     {
      int drawn = 0;
      for(int k = 0; k < SMC_OB_POOL && drawn < m_sObCount; k++)
        {
         if(!snap.sOb[k].active)
            continue;
         color c = (snap.sOb[k].bias == SMC_BULLISH) ? m_sObBull : m_sObBear;
         Rect("sob" + IntegerToString(k), snap.sOb[k].t0, snap.sOb[k].t1,
              snap.sOb[k].high, snap.sOb[k].low, c, c, true);
         drawn++;
        }
     }

   if(m_showFvg)
     {
      for(int k = 0; k < SMC_FVG_POOL; k++)
        {
         if(!snap.fvg[k].active)
            continue;
         color c = (snap.fvg[k].bias == SMC_BULLISH) ? m_fvgBull : m_fvgBear;
         double top, bot;
         SmcBoxEdges(snap.fvg[k], top, bot);
         double mid = (top + bot) * 0.5;
         Rect("fvgt" + IntegerToString(k), snap.fvg[k].t0, snap.fvg[k].t1, top, mid, c, c, true);
         Rect("fvgb" + IntegerToString(k), snap.fvg[k].t0, snap.fvg[k].t1, mid, bot, c, c, true);
        }
     }

   if(m_showStrong && SmcValid(snap.trailTop) && SmcValid(snap.trailBottom))
     {
      string topTxt = (snap.swingBias == SMC_BEARISH) ? "Strong High" : "Weak High";
      string botTxt = (snap.swingBias == SMC_BULLISH) ? "Strong Low" : "Weak Low";
      HLineSeg("sh", snap.trailTopTime, ext, snap.trailTop, sBear, STYLE_SOLID, 1);
      Txt("shl", ext, snap.trailTop, topTxt, sBear, m_swingFont, ANCHOR_LEFT_UPPER);
      HLineSeg("sl", snap.trailBotTime, ext, snap.trailBottom, sBull, STYLE_SOLID, 1);
      Txt("sll", ext, snap.trailBottom, botTxt, sBull, m_swingFont, ANCHOR_LEFT_LOWER);
     }

   if(m_showZones && SmcValid(snap.trailTop) && SmcValid(snap.trailBottom))
     {
      datetime left = snap.trailBarTime;
      if(left <= 0)
         left = now;
      Rect("zpre", left, now, snap.premiumTop, snap.premiumBot, m_prem, m_prem, true);
      Txt("zprel", left + (now - left) / 2, snap.premiumTop, "Premium", m_prem, 10, ANCHOR_LOWER);
      Rect("zeq", left, now, snap.eqTop, snap.eqBot, m_eq, m_eq, true);
      Txt("zeql", now, (snap.eqTop + snap.eqBot) * 0.5, "Equilibrium", m_eq, 10, ANCHOR_LEFT);
      Rect("zdis", left, now, snap.discountTop, snap.discountBot, m_disc, m_disc, true);
      Txt("zdisl", left + (now - left) / 2, snap.discountBot, "Discount", m_disc, 10, ANCHOR_UPPER);
     }

   if(m_showDaily && SmcValid(snap.pdh) && SmcValid(snap.pdl))
     {
      ENUM_LINE_STYLE st = LineStyle(m_dailyStyle);
      HLineSeg("pdh", now, ext, snap.pdh, m_daily, st, 1);
      Txt("pdhl", ext, snap.pdh, "PDH", m_daily, 10, ANCHOR_LEFT_UPPER);
      HLineSeg("pdl", now, ext, snap.pdl, m_daily, st, 1);
      Txt("pdll", ext, snap.pdl, "PDL", m_daily, 10, ANCHOR_LEFT_LOWER);
     }
   if(m_showWeekly && SmcValid(snap.pwh) && SmcValid(snap.pwl))
     {
      ENUM_LINE_STYLE st = LineStyle(m_weeklyStyle);
      HLineSeg("pwh", now, ext, snap.pwh, m_weekly, st, 1);
      Txt("pwhl", ext, snap.pwh, "PWH", m_weekly, 10, ANCHOR_LEFT_UPPER);
      HLineSeg("pwl", now, ext, snap.pwl, m_weekly, st, 1);
      Txt("pwll", ext, snap.pwl, "PWL", m_weekly, 10, ANCHOR_LEFT_LOWER);
     }
   if(m_showMonthly && SmcValid(snap.pmh) && SmcValid(snap.pml))
     {
      ENUM_LINE_STYLE st = LineStyle(m_monthlyStyle);
      HLineSeg("pmh", now, ext, snap.pmh, m_monthly, st, 1);
      Txt("pmhl", ext, snap.pmh, "PMH", m_monthly, 10, ANCHOR_LEFT_UPPER);
      HLineSeg("pml", now, ext, snap.pml, m_monthly, st, 1);
      Txt("pmll", ext, snap.pml, "PML", m_monthly, 10, ANCHOR_LEFT_LOWER);
     }

   ChartRedraw(m_chart);
  }

#endif
