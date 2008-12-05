//+------------------------------------------------------------------+
//|                                          TradingAllowedModul.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"
#property library

//+------------------------------------------------------------------+
//| TradeAllowed function return true if trading is possible         |
//+------------------------------------------------------------------+
bool TradeAllowed(int MAXORDERS)
{
//   static datetime LastBarTraded = 0;
//Trade only once on each bar
//   if(LastBarTraded == Time[0])
//      return(false);
//Trade only open price of current hour
//   if(iVolume(Symbol(), PERIOD_H1, 0) > 1)
//      return(false);
   if(!IsTradeAllowed()) 
      return(false);
   if(OrdersTotal() >= MAXORDERS)
      return(false);
   return(true);
}
//+------------------------------------------------------------------+
//| TradeAllowed function return true if trading is possible         |
//+------------------------------------------------------------------+
/*
bool IsTradingHour()
{
   int i;
   bool istradinghour = false;

   for(i = 0; i < ArraySize(TRADINGDAYHOURS); i++)
   {
      if(TRADINGDAYHOURS[i] == Hour())
      {
         istradinghour = true;
         break;
      }      
   }
   return(istradinghour);
}
*/