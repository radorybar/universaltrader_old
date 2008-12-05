//+------------------------------------------------------------------+
//|                                    OpenShortWithPendingHedge.mq4 |
//|                                                          navodar |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "navodar"
#property link      ""

extern double     _LOTS          = 0.1;
int        _STOPLOSS      = 0;
int        _TAKEPROFIT    = 0;
extern int        _HEDGEFROM     = 10;
extern int        _SLIPPAGE      = 3;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   double SL = 0, TP = 0;
   
//Place position with required SL and TP
   if(_STOPLOSS != 0)
      SL = Bid + _STOPLOSS*Point;
   if(_TAKEPROFIT != 0)
      TP = Bid - _TAKEPROFIT*Point;
   
   OrderSend(Symbol(), OP_SELL, _LOTS, Bid, _SLIPPAGE, SL, TP, NULL, 0, 0, Red);

//Place pending hedge position N-pips abowe Sell price 
   OrderSend(Symbol(), OP_BUYSTOP, _LOTS, Ask - (Ask - Bid) + _HEDGEFROM*Point, _SLIPPAGE, 0, 0, NULL, 0, 0, DimGray);

   return(0);
  }
//+------------------------------------------------------------------+