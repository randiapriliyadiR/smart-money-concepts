#property copyright "Smart Money Concepts"
#property version   "1.10"
#property description "OnInit smoke test for SMC engine/indicator formulas. Writes Common/Files/smc_smoke_result.txt"
#property strict

#include "Include/SmcSelfTest.mqh"

void SmcSmokeWrite(const int flags)
  {
   int fh = FileOpen("smc_smoke_result.txt", flags);
   if(fh == INVALID_HANDLE)
      return;
   FileWriteString(fh, "pass=" + IntegerToString(g_smcPass) + " fail=" + IntegerToString(g_smcFail) + "\n");
   if(g_smcFail > 0)
      FileWriteString(fh, "fails=" + g_smcFailNames + "\n");
   FileClose(fh);
  }

int OnInit()
  {
   SmcRunSelfTests();
   SmcSmokeWrite(FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   SmcSmokeWrite(FILE_WRITE | FILE_TXT | FILE_ANSI);
   Print("SMC smoke result pass=", g_smcPass, " fail=", g_smcFail);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
  }

void OnTick()
  {
   TesterStop();
  }
