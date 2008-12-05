//+------------------------------------------------------------------+
//|                                              OrderPlaceModul.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"

//+------------------------------------------------------------------------------------+
//| Opens position according to arguments (-1 short || 1 long, amount of Lots to trade |
//+------------------------------------------------------------------------------------+
void OpenPosition(bool SHORTLONG, double LOTS, int STOPLOSS, int TAKEPROFIT, int SLIPPAGE, int MAGICNUMBER)
{
   double SL, TP;
   if(SHORTLONG)
   {
      if(STOPLOSS != 0)
         SL = Bid + STOPLOSS * Point;
      else
         SL = 0;
      if(TAKEPROFIT != 0)
         TP = Bid - TAKEPROFIT * Point;
      else
         TP = 0;
      OrderSend(Symbol(), OP_SELL, LOTS, Bid, SLIPPAGE, SL, TP, TimeToStr(Time[0]), MAGICNUMBER, 0, Red);
   }
   else
   {
      if(STOPLOSS != 0)
         SL = Ask - STOPLOSS * Point;
      else
         SL = 0;
      if(TAKEPROFIT != 0)
         TP = Ask + TAKEPROFIT * Point;
      else
         TP = 0;
      OrderSend(Symbol(), OP_BUY, LOTS, Ask, SLIPPAGE, SL, TP, TimeToStr(Time[0]), MAGICNUMBER, 0, Blue);
   }
}

