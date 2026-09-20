#property copyright "Smart Money Concepts"
#property version   "1.1.0"
#property script_show_inputs
#property description "Offline checks for SmcEngine, confluence, and one-shot dedup"

// Copy this file to MQL5/Scripts/SMC_Test_SmcEngine.mq5 then compile.
#include "../Experts/Smart Money Concepts/Include/SmcSelfTest.mqh"

void OnStart()
  {
   SmcRunSelfTests();
  }
