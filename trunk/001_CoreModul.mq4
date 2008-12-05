//+------------------------------------------------------------------+
//|                                                001_CoreModul.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"

#include <TradingAllowedModul.mqh>
#include <MoneyManagementModul.mqh>
#include <OrderControlModul.mqh>
#include <OrderPlaceModul.mqh>
#include <SignalModul.mqh>

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----

   if(!TradeAllowed(1))
      return(0);
      
   if(CheckSignal(CLOSE_LONG_CCI_14_X100_0))
      CloseAllLongPositions(123456);
   if(CheckSignal(CLOSE_SHORT_CCI_14_XMIN100_0))
      CloseAllShortPositions(123456);
      
   if(CheckSignal(OPEN_LONG_SR_LEVELS))
      OpenPosition(false, 0.1, 10, 30, 3, 123456);
   if(CheckSignal(OPEN_SHORT_SR_LEVELS))
      OpenPosition(true, 0.1, 10, 30, 3, 123456);

//----
   return(0);
}
//+------------------------------------------------------------------+