#ifndef SMC_INDICATOR_APP_MQH
#define SMC_INDICATOR_APP_MQH

#include "SmcTypes.mqh"
#include "SmcEngine.mqh"
#include "SmcDraw.mqh"

input group "General"
input bool              InpShowDrawings   = true;
input ENUM_SMC_STYLE    InpStyle          = SMC_STYLE_COLORED;
input int               InpMaxStructure   = 10;          // Max Structure Drawings (4-20)
input int               InpCalcBars       = 500;         // Bars to calculate (100-2000)

input group "Internal Structure"
input bool              InpShowInternal   = true;
input ENUM_SMC_FILTER   InpInternalBull   = SMC_FILT_ALL;
input color             InpInternalBullC  = SMC_CLR_GREEN;
input ENUM_SMC_FILTER   InpInternalBear   = SMC_FILT_ALL;
input color             InpInternalBearC  = SMC_CLR_RED;
input bool              InpInternalConf   = false;       // Confluence Filter
input ENUM_SMC_FONT     InpInternalFont   = SMC_FONT_TINY;

input group "Swing Structure"
input bool              InpShowSwing      = true;
input ENUM_SMC_FILTER   InpSwingBull      = SMC_FILT_ALL;
input color             InpSwingBullC     = SMC_CLR_GREEN;
input ENUM_SMC_FILTER   InpSwingBear      = SMC_FILT_ALL;
input color             InpSwingBearC     = SMC_CLR_RED;
input ENUM_SMC_FONT     InpSwingFont      = SMC_FONT_SMALL;
input bool              InpShowSwingPts   = false;
input int               InpSwingsLength   = 50;
input bool              InpShowStrongWeak = true;

input group "Order Blocks"
input bool              InpShowInternalOb = true;
input int               InpInternalObCnt  = 5;
input bool              InpShowSwingOb    = true;
input int               InpSwingObCnt     = 5;
input ENUM_SMC_OB_FILTER InpObFilter      = SMC_OB_ATR;
input ENUM_SMC_OB_MIT   InpObMitigation   = SMC_OB_MIT_HL;
input color             InpIObBull        = SMC_CLR_IOB_BULL;
input color             InpIObBear        = SMC_CLR_IOB_BEAR;
input color             InpSObBull        = SMC_CLR_SOB_BULL;
input color             InpSObBear        = SMC_CLR_SOB_BEAR;

input group "Equal High/Low"
input bool              InpShowEqhl       = true;
input int               InpEqhlLength     = 3;
input double            InpEqhlThreshold  = 0.1;
input ENUM_SMC_FONT     InpEqhlFont       = SMC_FONT_TINY;

input group "Fair Value Gaps"
input bool              InpShowFvg        = true;
input bool              InpFvgAutoThr     = false;       // Auto Threshold (off for signal accuracy)
input ENUM_TIMEFRAMES   InpFvgTf          = PERIOD_CURRENT;
input color             InpFvgBull        = SMC_CLR_FVG_BULL;
input color             InpFvgBear        = SMC_CLR_FVG_BEAR;
input int               InpFvgExtend      = 5;

input group "Daily / Weekly / Monthly"
input bool              InpShowDaily      = false;
input ENUM_SMC_LINE     InpDailyStyle     = SMC_LINE_SOLID;
input color             InpDailyColor     = SMC_CLR_BLUE;
input bool              InpShowWeekly     = false;
input ENUM_SMC_LINE     InpWeeklyStyle    = SMC_LINE_SOLID;
input color             InpWeeklyColor    = SMC_CLR_BLUE;
input bool              InpShowMonthly    = false;
input ENUM_SMC_LINE     InpMonthlyStyle   = SMC_LINE_SOLID;
input color             InpMonthlyColor   = SMC_CLR_BLUE;

input group "Premium / Discount"
input bool              InpShowZones      = true;
input color             InpPremiumColor   = C'242,54,69';
input color             InpEqColor        = SMC_CLR_GRAY;
input color             InpDiscountColor  = C'8,153,129';

CSmcEngine g_engine;
CSmcDraw   g_draw;
datetime   g_lastBar = 0;
bool       g_ready = false;

void SmcIndFillSettings(SSmcSettings &s)
  {
   SmcSettingsDefault(s);
   s.calcBars = InpCalcBars;
   s.swingsLength = InpSwingsLength;
   s.maxStructure = InpMaxStructure;
   s.internalObCount = InpInternalObCnt;
   s.swingObCount = InpSwingObCnt;
   s.eqhlLength = InpEqhlLength;
   s.eqhlThreshold = InpEqhlThreshold;
   s.fvgExtend = InpFvgExtend;
   s.fvgAutoThreshold = InpFvgAutoThr;
   s.fvgTimeframe = InpFvgTf;
   s.showInternal = InpShowInternal;
   s.showSwing = InpShowSwing;
   s.showSwingPoints = InpShowSwingPts;
   s.showStrongWeak = InpShowStrongWeak;
   s.showInternalOb = InpShowInternalOb;
   s.showSwingOb = InpShowSwingOb;
   s.showEqhl = InpShowEqhl;
   s.showFvg = InpShowFvg;
   s.showDaily = InpShowDaily;
   s.showWeekly = InpShowWeekly;
   s.showMonthly = InpShowMonthly;
   s.showZones = InpShowZones;
   s.internalConfluence = InpInternalConf;
   s.internalBull = InpInternalBull;
   s.internalBear = InpInternalBear;
   s.swingBull = InpSwingBull;
   s.swingBear = InpSwingBear;
   s.obFilter = InpObFilter;
   s.obMitigation = InpObMitigation;
   s.style = InpStyle;
  }

void SmcIndApplyDwm(void)
  {
   double pdh, pdl, pwh, pwl, pmh, pml;
   datetime pdt, pwt, pmt;
   ENUM_TIMEFRAMES ctf = (ENUM_TIMEFRAMES)Period();
   SmcPrevPeriodHL(_Symbol, PERIOD_D1, ctf, pdh, pdl, pdt);
   SmcPrevPeriodHL(_Symbol, PERIOD_W1, ctf, pwh, pwl, pwt);
   SmcPrevPeriodHL(_Symbol, PERIOD_MN1, ctf, pmh, pml, pmt);
   g_engine.SetPrevPeriodLevels(pdh, pdl, pdt, pwh, pwl, pwt, pmh, pml, pmt);
  }

bool SmcIndRebuild(void)
  {
   SSmcSettings s;
   SmcIndFillSettings(s);
   g_engine.Init(s);
   MqlRates rates[];
   int got = SmcCopyRates(_Symbol, PERIOD_CURRENT, s.calcBars, rates);
   if(got < 20)
      return false;
   ENUM_TIMEFRAMES fvgTf = InpFvgTf;
   if(fvgTf == PERIOD_CURRENT)
      fvgTf = (ENUM_TIMEFRAMES)Period();
   if(InpShowFvg && fvgTf != (ENUM_TIMEFRAMES)Period())
     {
      MqlRates fvg[];
      SmcCopyRates(_Symbol, fvgTf, s.calcBars, fvg);
      g_engine.Process(rates, fvg);
     }
   else
      g_engine.Process(rates);
   SmcIndApplyDwm();
   g_draw.Configure(s, InpSwingBullC, InpSwingBearC, InpInternalBullC, InpInternalBearC,
                    InpIObBull, InpIObBear, InpSObBull, InpSObBear,
                    InpFvgBull, InpFvgBear, InpPremiumColor, InpEqColor, InpDiscountColor,
                    InpDailyColor, InpWeeklyColor, InpMonthlyColor,
                    InpDailyStyle, InpWeeklyStyle, InpMonthlyStyle,
                    InpInternalFont, InpSwingFont, InpEqhlFont);
   if(InpShowDrawings)
     {
      SSmcSnapshot snap;
      g_engine.GetSnapshot(snap);
      g_draw.Render(snap, _Symbol);
     }
   else
      g_draw.Clear();
   if(got > 0)
      g_lastBar = rates[got - 1].time;
   g_ready = true;
   return true;
  }

int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "SMC");
   g_draw.Clear();
   SmcIndRebuild();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   g_draw.Clear();
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < 20)
      return 0;
   datetime t = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(!g_ready || t != g_lastBar || prev_calculated == 0)
      SmcIndRebuild();
   else if(InpShowDrawings)
     {
      SSmcSnapshot snap;
      g_engine.GetSnapshot(snap);
      g_draw.Render(snap, _Symbol);
     }
   return rates_total;
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE && InpShowDrawings && g_ready)
     {
      SSmcSnapshot snap;
      g_engine.GetSnapshot(snap);
      g_draw.Render(snap, _Symbol);
     }
  }

#endif
