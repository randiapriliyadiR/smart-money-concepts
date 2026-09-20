#ifndef SMC_DEDUP_MQH
#define SMC_DEDUP_MQH

#include "SmcTypes.mqh"

#define SMC_DEDUP_MAX 512

class CSmcDedup
  {
private:
   string            m_sent[SMC_DEDUP_MAX];
   string            m_inside[SMC_DEDUP_MAX];
   string            m_seen[SMC_DEDUP_MAX];
   int               m_sentN;
   int               m_insideN;
   int               m_seenN;
   bool              m_loaded;
   bool              m_isolated;

   int               Find(const string &arr[], const int n, const string key) const;
   void              AddUnique(string &arr[], int &n, const string key);
   void              RemoveAt(string &arr[], int &n, const int idx);
   void              PersistSent(void);
   void              LoadSent(void);

public:
                     CSmcDedup(void);
   void              Load(void);
   void              Isolate(void);
   bool              ShouldSend(const string key, const bool insideNow);
   void              MarkSent(const string key);
   void              DropInside(const string key);
  };

CSmcDedup::CSmcDedup(void)
  {
   m_sentN = 0;
   m_insideN = 0;
   m_seenN = 0;
   m_loaded = false;
   m_isolated = false;
  }

void CSmcDedup::Isolate(void)
  {
   m_isolated = true;
   m_loaded = true;
   m_sentN = 0;
   m_insideN = 0;
   m_seenN = 0;
  }

int CSmcDedup::Find(const string &arr[], const int n, const string key) const
  {
   for(int i = 0; i < n; i++)
      if(arr[i] == key)
         return i;
   return -1;
  }

void CSmcDedup::AddUnique(string &arr[], int &n, const string key)
  {
   if(Find(arr, n, key) >= 0)
      return;
   if(n >= SMC_DEDUP_MAX)
     {
      for(int i = 1; i < SMC_DEDUP_MAX; i++)
         arr[i - 1] = arr[i];
      n = SMC_DEDUP_MAX - 1;
     }
   arr[n++] = key;
  }

void CSmcDedup::RemoveAt(string &arr[], int &n, const int idx)
  {
   if(idx < 0 || idx >= n)
      return;
   for(int i = idx + 1; i < n; i++)
      arr[i - 1] = arr[i];
   n--;
   if(n >= 0)
      arr[n] = "";
  }

void CSmcDedup::LoadSent(void)
  {
   m_sentN = 0;
   int fh = FileOpen(SMC_SENT_FILE, FILE_READ | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(fh == INVALID_HANDLE)
      return;
   while(!FileIsEnding(fh) && m_sentN < SMC_DEDUP_MAX)
     {
      string line = FileReadString(fh);
      StringTrimLeft(line);
      StringTrimRight(line);
      if(StringLen(line) > 0)
         m_sent[m_sentN++] = line;
     }
   FileClose(fh);
  }

void CSmcDedup::PersistSent(void)
  {
   int fh = FileOpen(SMC_SENT_FILE, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(fh != INVALID_HANDLE)
     {
      for(int i = 0; i < m_sentN; i++)
         FileWriteString(fh, m_sent[i] + "\n");
      FileClose(fh);
     }
   for(int i = 0; i < m_sentN; i++)
     {
      ulong h = SmcHashKey(m_sent[i]);
      string gv = SMC_GV_SENT_PREFIX + IntegerToString((long)(h % 1000000000));
      GlobalVariableSet(gv, 1.0);
     }
  }

void CSmcDedup::Load(void)
  {
   if(m_loaded)
      return;
   LoadSent();
   m_loaded = true;
  }

bool CSmcDedup::ShouldSend(const string key, const bool insideNow)
  {
   Load();
   bool seen = (Find(m_seen, m_seenN, key) >= 0);
   bool wasInside = (Find(m_inside, m_insideN, key) >= 0);
   bool sent = (Find(m_sent, m_sentN, key) >= 0);
   if(!sent && !m_isolated)
     {
      ulong h = SmcHashKey(key);
      string gv = SMC_GV_SENT_PREFIX + IntegerToString((long)(h % 1000000000));
      sent = GlobalVariableCheck(gv);
     }
   if(insideNow)
      AddUnique(m_inside, m_insideN, key);
   else
     {
      int idx = Find(m_inside, m_insideN, key);
      if(idx >= 0)
         RemoveAt(m_inside, m_insideN, idx);
     }
   if(!seen)
     {
      AddUnique(m_seen, m_seenN, key);
      return false;
     }
   if(!insideNow)
      return false;
   if(sent)
      return false;
   if(wasInside)
      return false;
   return true;
  }

void CSmcDedup::MarkSent(const string key)
  {
   AddUnique(m_sent, m_sentN, key);
   AddUnique(m_inside, m_insideN, key);
   if(!m_isolated)
      PersistSent();
  }

void CSmcDedup::DropInside(const string key)
  {
   int idx = Find(m_inside, m_insideN, key);
   if(idx >= 0)
      RemoveAt(m_inside, m_insideN, idx);
  }

#endif
