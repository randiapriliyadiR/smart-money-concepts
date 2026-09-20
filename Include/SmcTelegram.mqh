#ifndef SMC_TELEGRAM_MQH
#define SMC_TELEGRAM_MQH

#include "SmcTypes.mqh"
#include "SmcConfluence.mqh"

class CSmcTelegram
  {
private:
   string            m_token;
   string            m_chat;
   int               m_topic;
   bool              m_silent;
   string            m_lastError;

   string            FormatPrice(const string symbol, const double price) const;
   bool              Post(const string text);

public:
                     CSmcTelegram(void);
   void              Configure(const string token, const string chat, const int topic, const bool silent);
   bool              Ready(void) const;
   string            LastError(void) const { return m_lastError; }
   bool              SendAlert(const SSmcAlert &a);
   bool              SendOnline(const string symbols, const ENUM_TIMEFRAMES biasTf, const string signalTfs);
  };

CSmcTelegram::CSmcTelegram(void)
  {
   m_token = "";
   m_chat = "";
   m_topic = 0;
   m_silent = false;
   m_lastError = "";
  }

void CSmcTelegram::Configure(const string token, const string chat, const int topic, const bool silent)
  {
   m_token = token;
   m_chat = chat;
   m_topic = topic;
   m_silent = silent;
   StringTrimLeft(m_token);
   StringTrimRight(m_token);
   StringTrimLeft(m_chat);
   StringTrimRight(m_chat);
  }

bool CSmcTelegram::Ready(void) const
  {
   return (StringLen(m_token) > 10 && StringLen(m_chat) > 0);
  }

string CSmcTelegram::FormatPrice(const string symbol, const double price) const
  {
   int dg = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return DoubleToString(price, dg);
  }

bool CSmcTelegram::Post(const string text)
  {
   m_lastError = "";
   if(!Ready())
     {
      m_lastError = "token/chat empty";
      return false;
     }
   string url = "https://api.telegram.org/bot" + m_token + "/sendMessage";
   string body = "chat_id=" + SmcUrlEncode(m_chat) +
                 "&text=" + SmcUrlEncode(text) +
                 "&parse_mode=HTML" +
                 "&disable_web_page_preview=true";
   if(m_silent)
      body += "&disable_notification=true";
   if(m_topic > 0)
      body += "&message_thread_id=" + IntegerToString(m_topic);

   uchar data[];
   int n = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   if(n > 0 && data[n - 1] == 0)
      ArrayResize(data, n - 1);

   uchar result[];
   string resultHeaders;
   string headers = "Content-Type: application/x-www-form-urlencoded\r\n";
   ResetLastError();
   int code = WebRequest("POST", url, headers, 10000, data, result, resultHeaders);
   if(code == -1)
     {
      m_lastError = "WebRequest err " + IntegerToString(GetLastError()) +
                    " — allow https://api.telegram.org";
      Print(m_lastError);
      return false;
     }
   string json = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   if(code != 200 || StringFind(json, "\"ok\":true") < 0)
     {
      m_lastError = "Telegram HTTP " + IntegerToString(code) + " " + json;
      Print(m_lastError);
      return false;
     }
   return true;
  }

bool CSmcTelegram::SendAlert(const SSmcAlert &a)
  {
   string dirTxt = (a.dir == SMC_DIR_BUY) ? "BUY" : "SELL";
   string dirIco = (a.dir == SMC_DIR_BUY) ? "🟢" : "🔴";
   string biasIco = (a.bias == SMC_BULLISH) ? "📈" : "📉";
   string biasTxt = (a.bias == SMC_BULLISH) ? "Bullish" : "Bearish";
   string zoneIco = "📦";
   if(a.zone == SMC_ZONE_INT_OB)
      zoneIco = "🗂";
   if(a.zone == SMC_ZONE_FVG)
      zoneIco = "⚡";
   string sym = SmcDisplaySymbol(a.symbol);
   SmcHtmlEscape(sym);
   string zone = SmcZoneText(a.zone);
   string pd = SmcPdText(a.pd);
   string text =
      dirIco + " <b>SMC " + dirTxt + "</b> · " + sym + " · " + SmcTfShort(a.signalTf) + "\n\n" +
      biasIco + " Bias " + SmcTfShort(a.biasTf) + ": " + biasTxt + "\n" +
      "🎯 Entry: " + pd + "\n" +
      zoneIco + " Zone: " + zone + "\n" +
      "📏 Range: " + FormatPrice(a.symbol, a.zoneLow) + " – " + FormatPrice(a.symbol, a.zoneHigh) + "\n" +
      "💵 Price: " + FormatPrice(a.symbol, a.price);
   return Post(text);
  }

bool CSmcTelegram::SendOnline(const string symbols, const ENUM_TIMEFRAMES biasTf, const string signalTfs)
  {
   string topicLine = (m_topic > 0) ? ("📢 Chat OK · 💬 Topic " + IntegerToString(m_topic))
                                    : "📢 Chat OK · 💬 Topic none";
   string text =
      "✅ <b>SMC Scanner</b> online\n" +
      topicLine + "\n" +
      "📊 " + symbols + "\n" +
      "📈 Bias " + SmcTfShort(biasTf) + " · Signal " + signalTfs;
   return Post(text);
  }

#endif
