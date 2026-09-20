#ifndef SMC_TYPES_MQH
#define SMC_TYPES_MQH

#define SMC_VERSION              "1.1.1"
#define SMC_OBJ_PREFIX           "SMC:"
#define SMC_GV_SENT_PREFIX       "SMC.sent."
#define SMC_SENT_FILE            "smc_sent_keys.csv"

#define SMC_BULLISH_LEG          1
#define SMC_BEARISH_LEG          0
#define SMC_BULLISH              1
#define SMC_BEARISH             -1
#define SMC_BIAS_NONE            0

#define SMC_MAX_BARS             2000
#define SMC_OB_POOL              8
#define SMC_FVG_POOL             6
#define SMC_STRUCT_POOL          20
#define SMC_EQHL_POOL            6
#define SMC_SWING_LBL_POOL       6
#define SMC_OB_LOOKBACK          60
#define SMC_LINE_EXTEND_BARS     20
#define SMC_ATR_LEN              100
#define SMC_INTERNAL_LEN         5
#define SMC_DEFAULT_SWING_LEN    50
#define SMC_DEFAULT_CALC_BARS    500
#define SMC_DEFAULT_FVG_EXTEND   5
#define SMC_DEFAULT_OB_COUNT     5
#define SMC_DEFAULT_MAX_STRUCT   10

#define SMC_CLR_GREEN            C'8,153,129'
#define SMC_CLR_RED              C'242,54,69'
#define SMC_CLR_BLUE             C'33,87,243'
#define SMC_CLR_GRAY             C'135,139,148'
#define SMC_CLR_MONO_BULL        C'178,181,190'
#define SMC_CLR_MONO_BEAR        C'93,96,107'
#define SMC_CLR_IOB_BULL         C'49,121,245'
#define SMC_CLR_IOB_BEAR         C'247,124,128'
#define SMC_CLR_SOB_BULL         C'24,72,204'
#define SMC_CLR_SOB_BEAR         C'178,40,51'
#define SMC_CLR_FVG_BULL         C'0,255,104'
#define SMC_CLR_FVG_BEAR         C'255,0,8'

enum ENUM_SMC_STYLE
  {
   SMC_STYLE_COLORED = 0,
   SMC_STYLE_MONO    = 1
  };

enum ENUM_SMC_FILTER
  {
   SMC_FILT_ALL   = 0,
   SMC_FILT_BOS   = 1,
   SMC_FILT_CHOCH = 2
  };

enum ENUM_SMC_OB_FILTER
  {
   SMC_OB_ATR = 0,
   SMC_OB_CMR = 1
  };

enum ENUM_SMC_OB_MIT
  {
   SMC_OB_MIT_HL    = 0,
   SMC_OB_MIT_CLOSE = 1
  };

enum ENUM_SMC_LINE
  {
   SMC_LINE_SOLID  = 0,
   SMC_LINE_DASHED = 1,
   SMC_LINE_DOTTED = 2
  };

enum ENUM_SMC_FONT
  {
   SMC_FONT_TINY   = 0,
   SMC_FONT_SMALL  = 1,
   SMC_FONT_NORMAL = 2
  };

enum ENUM_SMC_TAG
  {
   SMC_TAG_NONE  = 0,
   SMC_TAG_BOS   = 1,
   SMC_TAG_CHOCH = 2,
   SMC_TAG_HH    = 3,
   SMC_TAG_HL    = 4,
   SMC_TAG_LH    = 5,
   SMC_TAG_LL    = 6,
   SMC_TAG_EQH   = 7,
   SMC_TAG_EQL   = 8
  };

enum ENUM_SMC_ZONE
  {
   SMC_ZONE_NONE     = 0,
   SMC_ZONE_SWING_OB = 1,
   SMC_ZONE_INT_OB   = 2,
   SMC_ZONE_FVG      = 3
  };

enum ENUM_SMC_DIR
  {
   SMC_DIR_NONE = 0,
   SMC_DIR_BUY  = 1,
   SMC_DIR_SELL = -1
  };

enum ENUM_SMC_PD
  {
   SMC_PD_NONE       = 0,
   SMC_PD_PREMIUM    = 1,
   SMC_PD_EQUILIBRIUM= 2,
   SMC_PD_DISCOUNT   = 3
  };

struct SSmcSettings
  {
   int                calcBars;
   int                swingsLength;
   int                maxStructure;
   int                internalObCount;
   int                swingObCount;
   int                eqhlLength;
   double             eqhlThreshold;
   int                fvgExtend;
   bool               fvgAutoThreshold;
   bool               fvgOnOwnRates;
   ENUM_TIMEFRAMES    fvgTimeframe;
   bool               showInternal;
   bool               showSwing;
   bool               showSwingPoints;
   bool               showStrongWeak;
   bool               showInternalOb;
   bool               showSwingOb;
   bool               showEqhl;
   bool               showFvg;
   bool               showDaily;
   bool               showWeekly;
   bool               showMonthly;
   bool               showZones;
   bool               internalConfluence;
   ENUM_SMC_FILTER    internalBull;
   ENUM_SMC_FILTER    internalBear;
   ENUM_SMC_FILTER    swingBull;
   ENUM_SMC_FILTER    swingBear;
   ENUM_SMC_OB_FILTER obFilter;
   ENUM_SMC_OB_MIT    obMitigation;
   ENUM_SMC_STYLE     style;
  };

struct SSmcBox
  {
   bool               active;
   int                bias;
   datetime           t0;
   datetime           t1;
   double             high;
   double             low;
  };

struct SSmcStructEvent
  {
   bool               filled;
   bool               dashed;
   int                bias;
   ENUM_SMC_TAG       tag;
   datetime           t0;
   datetime           t1;
   double             level;
  };

struct SSmcEqEvent
  {
   bool               filled;
   int                bias;
   ENUM_SMC_TAG       tag;
   datetime           t0;
   datetime           t1;
   double             p0;
   double             p1;
  };

struct SSmcSwingLbl
  {
   bool               filled;
   bool               below;
   int                bias;
   ENUM_SMC_TAG       tag;
   datetime           t0;
   double             price;
  };

struct SSmcSnapshot
  {
   int                swingBias;
   int                internalBias;
   datetime           trailTopTime;
   datetime           trailBotTime;
   datetime           trailBarTime;
   double             trailTop;
   double             trailBottom;
   double             premiumTop;
   double             premiumBot;
   double             eqTop;
   double             eqBot;
   double             discountTop;
   double             discountBot;
   double             pdh;
   double             pdl;
   double             pwh;
   double             pwl;
   double             pmh;
   double             pml;
   datetime           pdTime;
   datetime           pwTime;
   datetime           pmTime;
   int                structCount;
   int                eqCount;
   int                swingLblCount;
   SSmcStructEvent    structs[SMC_STRUCT_POOL];
   SSmcEqEvent        eqhl[SMC_EQHL_POOL];
   SSmcSwingLbl       swingLbls[SMC_SWING_LBL_POOL];
   SSmcBox            iOb[SMC_OB_POOL];
   SSmcBox            sOb[SMC_OB_POOL];
   SSmcBox            fvg[SMC_FVG_POOL];
  };

struct SSmcAlert
  {
   bool               valid;
   ENUM_SMC_DIR       dir;
   ENUM_SMC_ZONE      zone;
   ENUM_SMC_PD        pd;
   ENUM_TIMEFRAMES    signalTf;
   ENUM_TIMEFRAMES    biasTf;
   int                bias;
   datetime           zoneTime;
   double             zoneHigh;
   double             zoneLow;
   double             price;
   string             symbol;
  };

void SmcSettingsDefault(SSmcSettings &s)
  {
   s.calcBars = SMC_DEFAULT_CALC_BARS;
   s.swingsLength = SMC_DEFAULT_SWING_LEN;
   s.maxStructure = SMC_DEFAULT_MAX_STRUCT;
   s.internalObCount = SMC_DEFAULT_OB_COUNT;
   s.swingObCount = SMC_DEFAULT_OB_COUNT;
   s.eqhlLength = 3;
   s.eqhlThreshold = 0.1;
   s.fvgExtend = SMC_DEFAULT_FVG_EXTEND;
   s.fvgAutoThreshold = false;
   s.fvgOnOwnRates = true;
   s.fvgTimeframe = PERIOD_CURRENT;
   s.showInternal = true;
   s.showSwing = true;
   s.showSwingPoints = false;
   s.showStrongWeak = true;
   s.showInternalOb = true;
   s.showSwingOb = true;
   s.showEqhl = true;
   s.showFvg = true;
   s.showDaily = false;
   s.showWeekly = false;
   s.showMonthly = false;
   s.showZones = true;
   s.internalConfluence = false;
   s.internalBull = SMC_FILT_ALL;
   s.internalBear = SMC_FILT_ALL;
   s.swingBull = SMC_FILT_ALL;
   s.swingBear = SMC_FILT_ALL;
   s.obFilter = SMC_OB_ATR;
   s.obMitigation = SMC_OB_MIT_HL;
   s.style = SMC_STYLE_COLORED;
  }

void SmcSnapshotClear(SSmcSnapshot &snap)
  {
   ZeroMemory(snap);
   snap.trailTop = EMPTY_VALUE;
   snap.trailBottom = EMPTY_VALUE;
   snap.premiumTop = EMPTY_VALUE;
   snap.premiumBot = EMPTY_VALUE;
   snap.eqTop = EMPTY_VALUE;
   snap.eqBot = EMPTY_VALUE;
   snap.discountTop = EMPTY_VALUE;
   snap.discountBot = EMPTY_VALUE;
   snap.pdh = EMPTY_VALUE;
   snap.pdl = EMPTY_VALUE;
   snap.pwh = EMPTY_VALUE;
   snap.pwl = EMPTY_VALUE;
   snap.pmh = EMPTY_VALUE;
   snap.pml = EMPTY_VALUE;
  }

int SmcFontPx(const ENUM_SMC_FONT sz)
  {
   if(sz == SMC_FONT_TINY)
      return 8;
   if(sz == SMC_FONT_NORMAL)
      return 12;
   return 10;
  }

bool SmcTagAllowed(const ENUM_SMC_FILTER filt, const ENUM_SMC_TAG tag)
  {
   if(filt == SMC_FILT_ALL)
      return true;
   if(filt == SMC_FILT_BOS && tag == SMC_TAG_BOS)
      return true;
   if(filt == SMC_FILT_CHOCH && tag == SMC_TAG_CHOCH)
      return true;
   return false;
  }

string SmcTagText(const ENUM_SMC_TAG tag)
  {
   switch(tag)
     {
      case SMC_TAG_BOS:   return "BOS";
      case SMC_TAG_CHOCH: return "CHoCH";
      case SMC_TAG_HH:    return "HH";
      case SMC_TAG_HL:    return "HL";
      case SMC_TAG_LH:    return "LH";
      case SMC_TAG_LL:    return "LL";
      case SMC_TAG_EQH:   return "EQH";
      case SMC_TAG_EQL:   return "EQL";
     }
   return "";
  }

string SmcZoneText(const ENUM_SMC_ZONE z)
  {
   switch(z)
     {
      case SMC_ZONE_SWING_OB: return "Swing OB";
      case SMC_ZONE_INT_OB:   return "Internal OB";
      case SMC_ZONE_FVG:      return "FVG";
     }
   return "";
  }

string SmcPdText(const ENUM_SMC_PD pd)
  {
   if(pd == SMC_PD_PREMIUM)
      return "Premium";
   if(pd == SMC_PD_DISCOUNT)
      return "Discount";
   if(pd == SMC_PD_EQUILIBRIUM)
      return "Equilibrium";
   return "";
  }

string SmcTfShort(const ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
     }
   return EnumToString(tf);
  }

ENUM_TIMEFRAMES SmcTfFromString(string s)
  {
   StringTrimLeft(s);
   StringTrimRight(s);
   StringToUpper(s);
   if(s == "M1" || s == "1")
      return PERIOD_M1;
   if(s == "M5" || s == "5")
      return PERIOD_M5;
   if(s == "M15" || s == "15")
      return PERIOD_M15;
   if(s == "M30" || s == "30")
      return PERIOD_M30;
   if(s == "H1" || s == "60")
      return PERIOD_H1;
   if(s == "H4" || s == "240")
      return PERIOD_H4;
   if(s == "D1" || s == "DAILY" || s == "1D")
      return PERIOD_D1;
   if(s == "W1" || s == "WEEKLY")
      return PERIOD_W1;
   if(s == "MN1" || s == "MONTHLY")
      return PERIOD_MN1;
   return PERIOD_CURRENT;
  }

ENUM_TIMEFRAMES SmcNextHigherTf(const ENUM_TIMEFRAMES tf)
  {
   if(tf < PERIOD_M5)
      return PERIOD_M5;
   if(tf < PERIOD_M15)
      return PERIOD_M15;
   if(tf < PERIOD_M30)
      return PERIOD_M30;
   if(tf < PERIOD_H1)
      return PERIOD_H1;
   if(tf < PERIOD_H4)
      return PERIOD_H4;
   if(tf < PERIOD_D1)
      return PERIOD_D1;
   if(tf < PERIOD_W1)
      return PERIOD_W1;
   return PERIOD_MN1;
  }

ENUM_TIMEFRAMES SmcBiasTfForSignal(const ENUM_TIMEFRAMES signalTf, const ENUM_TIMEFRAMES biasTf)
  {
   ENUM_TIMEFRAMES sig = signalTf;
   if(sig == PERIOD_CURRENT)
      sig = (ENUM_TIMEFRAMES)Period();
   ENUM_TIMEFRAMES bias = biasTf;
   if(bias == PERIOD_CURRENT)
      bias = (ENUM_TIMEFRAMES)Period();
   if(sig < bias)
      return bias;
   return SmcNextHigherTf(sig);
  }

bool SmcValid(const double v)
  {
   return (v != EMPTY_VALUE && MathIsValidNumber(v));
  }

int SmcPriceToPoints(const string symbol, const double price)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double pt = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(pt <= 0.0)
      return 0;
   return (int)MathRound(price / pt);
  }

ulong SmcHashKey(const string key)
  {
   uchar bytes[];
   int n = StringToCharArray(key, bytes, 0, WHOLE_ARRAY, CP_UTF8);
   ulong h = 14695981039346656037;
   for(int i = 0; i < n; i++)
     {
      if(bytes[i] == 0)
         continue;
      h ^= (ulong)bytes[i];
      h *= 1099511628211;
     }
   return h;
  }

void SmcHtmlEscape(string &s)
  {
   StringReplace(s, "&", "&amp;");
   StringReplace(s, "<", "&lt;");
   StringReplace(s, ">", "&gt;");
  }

string SmcUrlEncode(const string src)
  {
   uchar srcb[];
   int n = StringToCharArray(src, srcb, 0, WHOLE_ARRAY, CP_UTF8);
   if(n > 0 && srcb[n - 1] == 0)
      n--;
   string out = "";
   for(int i = 0; i < n; i++)
     {
      uchar c = srcb[i];
      bool safe = ((c >= 'A' && c <= 'Z') ||
                   (c >= 'a' && c <= 'z') ||
                   (c >= '0' && c <= '9') ||
                   c == '-' || c == '_' || c == '.' || c == '~');
      if(safe)
         out += CharToString(c);
      else if(c == ' ')
         out += "+";
      else
         out += StringFormat("%%%02X", c);
     }
   return out;
  }

string SmcResolveSymbol(const string raw)
  {
   string name = raw;
   StringTrimLeft(name);
   StringTrimRight(name);
   if(name == "")
      return "";
   if(SymbolSelect(name, true))
      return name;
   int total = SymbolsTotal(true);
   for(int i = 0; i < total; i++)
     {
      string s = SymbolName(i, true);
      if(StringFind(s, name) != 0)
         continue;
      int extra = StringLen(s) - StringLen(name);
      if(extra >= 0 && extra <= 8)
        {
         SymbolSelect(s, true);
         return s;
        }
     }
   total = SymbolsTotal(false);
   for(int i = 0; i < total; i++)
     {
      string s = SymbolName(i, false);
      if(StringFind(s, name) != 0)
         continue;
      int extra = StringLen(s) - StringLen(name);
      if(extra >= 0 && extra <= 8)
        {
         SymbolSelect(s, true);
         return s;
        }
     }
   return name;
  }

void SmcBoxEdges(const SSmcBox &b, double &top, double &bot)
  {
   top = MathMax(b.high, b.low);
   bot = MathMin(b.high, b.low);
  }

bool SmcPriceInBox(const SSmcBox &b, const double price)
  {
   if(!b.active)
      return false;
   double top, bot;
   SmcBoxEdges(b, top, bot);
   return (price >= bot && price <= top);
  }

ENUM_SMC_PD SmcPdAt(const SSmcSnapshot &snap, const double price)
  {
   if(!SmcValid(snap.trailTop) || !SmcValid(snap.trailBottom))
      return SMC_PD_NONE;
   if(price >= snap.premiumBot)
      return SMC_PD_PREMIUM;
   if(price <= snap.discountTop)
      return SMC_PD_DISCOUNT;
   return SMC_PD_EQUILIBRIUM;
  }

int SmcCopyRates(const string symbol, const ENUM_TIMEFRAMES tf, const int bars, MqlRates &rates[])
  {
   int need = bars;
   if(need < 100)
      need = 100;
   if(need > SMC_MAX_BARS)
      need = SMC_MAX_BARS;
   ArraySetAsSeries(rates, false);
   int got = CopyRates(symbol, tf, 0, need, rates);
   if(got <= 0)
      return 0;
   if(got > 1 && rates[0].time > rates[got - 1].time)
     {
      for(int a = 0; a < got / 2; a++)
        {
         MqlRates tmp = rates[a];
         rates[a] = rates[got - 1 - a];
         rates[got - 1 - a] = tmp;
        }
     }
   return got;
  }

bool SmcPrevPeriodHL(const string symbol, const ENUM_TIMEFRAMES tf, const ENUM_TIMEFRAMES chartTf,
                     double &hi, double &lo, datetime &t)
  {
   hi = EMPTY_VALUE;
   lo = EMPTY_VALUE;
   t = 0;
   MqlRates r[];
   int got = CopyRates(symbol, tf, 0, 3, r);
   if(got < 1)
      return false;
   ArraySetAsSeries(r, true);
   ENUM_TIMEFRAMES ctf = chartTf;
   if(ctf == PERIOD_CURRENT)
      ctf = (ENUM_TIMEFRAMES)Period();
   if(ctf == tf)
     {
      hi = r[0].high;
      lo = r[0].low;
      t = r[0].time;
      return true;
     }
   if(got < 2)
      return false;
   hi = r[1].high;
   lo = r[1].low;
   t = r[1].time;
   return true;
  }

string SmcDisplaySymbol(const string symbol)
  {
   string bases[] = {"XAUUSD","XAGUSD","EURUSD","GBPUSD","USDJPY","USDCHF",
                     "AUDUSD","USDCAD","NZDUSD","EURGBP","EURJPY","GBPJPY"};
   for(int i = 0; i < ArraySize(bases); i++)
     {
      if(StringFind(symbol, bases[i]) == 0)
         return bases[i];
     }
   return symbol;
  }

#endif
