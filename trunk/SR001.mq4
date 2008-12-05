//+------------------------------------------------------------------+
//|                                              SuperWoodiesCCI.mq4 |
//|                                                           duckfu |
//|                                          http://www.dopeness.org |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      ""

#define  MAGICMA           0

string   SYMBOL            = "EURUSD";
int      TIMEFRAME         = PERIOD_M15;
int      MAXORDERS         = 1;

//Expert Settings
double   LOTS              = 0.1;
double   MAXIMUMRISK       = 0;
int      SLIPPAGE          = 3;

double   STOPLOSS          = 15;
double   TRAILINGSTOP      = 15;
double   TAKEPROFIT        = 0;

//Slow
double   MA1MOVINGPERIOD   = 300;
double   MA1MOVINGSHIFT    = 0;
int      MA1MODE           = MODE_SMA;
int      MA1PRICE          = PRICE_CLOSE;

//Fast
double   MA2MOVINGPERIOD   = 6;
double   MA2MOVINGSHIFT    = 0;
int      MA2MODE           = MODE_SMA;
int      MA2PRICE          = PRICE_CLOSE;

//Globals
datetime LastBarTraded     = 0;

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
void start()
{
   if(!TradeAllowed())
      return;
   CheckForClosePositions();   
   CheckForModifyPositions();
   OpenPosition(CheckForOpenPosition(), GetLots());
}
//+------------------------------------------------------------------+
//| TradeAllowed function return true if trading is possible         |
//+------------------------------------------------------------------+
bool TradeAllowed()
{
//Trade only once on each bar
   if(LastBarTraded == Time[0])
      return(false);
//Trade only for open price
//   if(Volume[0]>1)
//      return(false);
   if(!IsTradeAllowed()) 
      return(false);
   if(OrdersTotal() >= MAXORDERS)
      return(false);
   return(true);
}
//+------------------------------------------------------------------+
//| Get amount of lots to trade                                      |
//+------------------------------------------------------------------+
double GetLots()
{
   double lot;
   lot = NormalizeDouble(AccountFreeMargin() * MAXIMUMRISK / 1000.0, 1);
   if(lot == 0)
      lot = LOTS;
   if(lot < 0.1)
      lot = 0.1;
   else if(lot > 5)
      lot = 5;
   return(lot);
}
//+------------------------------------------------------------------+
//| Checks of open short, long or nothing (-1, 1, 0)                 |
//+------------------------------------------------------------------+
int CheckForOpenPosition()
{
   int     _PERIOD   = PERIOD_H1;
   int     _RANGE    = 600;
   int     _MAXAGE   = 48;
   int     _DISTANCE = 10;

   int result = 0;
   
   double LastUpFractalValue = 0;
   double LastLowFractalValue = 0;
   double UpFractalValue = 0;
   double LowFractalValue = 0;
   
   int max = ObjectsTotal();
   for(int i = max-1; i >= 0; i--)
   {
      if(StringFind(ObjectName(i), "support") == 0 || StringFind(ObjectName(i), "resistance") == 0)
      {
         if(Ask < ObjectGetValueByShift(ObjectName(i), 0) && Ask + _DISTANCE*Point >= ObjectGetValueByShift(ObjectName(i), 0))
         {
            result = 1;
//            Print(ObjectGetValueByShift(ObjectName(i), 0) - Ask);
         }
         if(Bid > ObjectGetValueByShift(ObjectName(i), 0) && Bid - _DISTANCE*Point <= ObjectGetValueByShift(ObjectName(i), 0))
         {
            result = -1;
//            Print(Bid - ObjectGetValueByShift(ObjectName(i), 0));
         }
         ObjectDelete(ObjectName(i));
      }
	}
   
   for(i = 1; i <= _MAXAGE; i++)
   {
      UpFractalValue = iFractals(NULL, _PERIOD, MODE_UPPER, i);
      LowFractalValue = iFractals(NULL, _PERIOD, MODE_LOWER, i);
      
      if(UpFractalValue != 0)
         if(UpFractalValue != LastUpFractalValue)
            if(MathAbs(UpFractalValue - Ask) < _RANGE * Point/2)
            {
               ObjectCreate(StringConcatenate("resistance", i) , OBJ_TREND, 0, Time[0] -_PERIOD*i*60, UpFractalValue, Time[0], UpFractalValue);
               ObjectSet(StringConcatenate("resistance", i), OBJPROP_COLOR, Blue);
               ObjectSet(StringConcatenate("resistance", i), OBJPROP_STYLE, STYLE_DOT);
            }

      if(LowFractalValue != 0)
         if(LowFractalValue != LastLowFractalValue)
            if(MathAbs(LowFractalValue - Bid) < _RANGE * Point/2)
            {
               ObjectCreate(StringConcatenate("support", i) , OBJ_TREND, 0, Time[0] -_PERIOD*i*60, LowFractalValue, Time[0], LowFractalValue);
               ObjectSet(StringConcatenate("support", i), OBJPROP_COLOR, Red);
               ObjectSet(StringConcatenate("support", i), OBJPROP_STYLE, STYLE_DOT);
            }

      LastUpFractalValue = UpFractalValue;
      LastLowFractalValue = LowFractalValue;
   }   
   
   return(result);
}
//+------------------------------------------------------------------------------------+
//| Opens position according to arguments (-1 short || 1 long, amount of Lots to trade |
//+------------------------------------------------------------------------------------+
void OpenPosition(int ShortLong, double Lots)
{
   double SL, TP;
   if(ShortLong == -1)
   {
      if(STOPLOSS != 0)
         SL = Bid + STOPLOSS * Point;
      else
         SL = 0;
      if(TAKEPROFIT != 0)
         TP = Bid - TAKEPROFIT * Point;
      else
         TP = 0;
      OrderSend(SYMBOL, OP_SELL, Lots, Bid, SLIPPAGE, SL, TP, TimeToStr(Time[0]), MAGICMA, 0, Red);
   }
   else if(ShortLong == 1)
   {
      if(STOPLOSS != 0)
         SL = Ask - STOPLOSS * Point;
      else
         SL = 0;
      if(TAKEPROFIT != 0)
         TP = Ask + TAKEPROFIT * Point;
      else
         TP = 0;
      OrderSend(SYMBOL, OP_BUY, Lots, Ask, SLIPPAGE, SL, TP, TimeToStr(Time[0]), MAGICMA, 0, Blue);
   }
   if(ShortLong != 0)
      LastBarTraded = Time[0];
   return;
}
//+------------------------------------------------------------------------------------+
//| Closes position based on indicator state                                           |
//+------------------------------------------------------------------------------------+
void CheckForClosePositions()
{
   double         ma1,
                  ma2,
                  ma1Prev,
                  ma2Prev;
   int            i, j;

   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);

//---- get Moving Averages 
   ma1=iMA(SYMBOL, TIMEFRAME, MA1MOVINGPERIOD, MA1MOVINGSHIFT, MA1MODE, MA1PRICE, 0);
   ma2=iMA(SYMBOL, TIMEFRAME, MA2MOVINGPERIOD, MA2MOVINGSHIFT, MA2MODE, MA2PRICE, 0);
   ma1Prev=iMA(SYMBOL, TIMEFRAME, MA1MOVINGPERIOD, MA1MOVINGSHIFT, PRICE_OPEN, MA1PRICE, 1);
   ma2Prev=iMA(SYMBOL, TIMEFRAME, MA2MOVINGPERIOD, MA2MOVINGSHIFT, PRICE_OPEN, MA2PRICE, 1);

//Close all Long position   
   j = 0;
   if(ma1Prev < ma2Prev && ma1 >= ma2)
      for(i = 0; i < OrdersTotal(); i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderType() == OP_BUY)
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
      }
   else if(ma1Prev > ma2Prev && ma1 <= ma2)
      for(i = 0; i < OrdersTotal(); i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderType() == OP_SELL)
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
      }
   for(i = 0; i < ArraySize(OrderTickets2Close); i++)
   {
      OrderSelect(OrderTickets2Close[i], SELECT_BY_TICKET);
      if(OrderType() == OP_SELL)
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, Orange);
      else if(OrderType() == OP_BUY)
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, Orange);
   }

//----
   return;
}
//+------------------------------------------------------------------------------------+
//| Modify positions - Stoploss based on Trailing stop                                            |
//+------------------------------------------------------------------------------------+
void CheckForModifyPositions()
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         break;
      if(OrderMagicNumber() != MAGICMA || OrderSymbol() != SYMBOL)
         continue;

      if(OrderType() == OP_BUY)
      {
         if(TRAILINGSTOP > 0)
            if(Bid - OrderOpenPrice() > Point * TRAILINGSTOP)
              if(OrderStopLoss() < Bid-Point * TRAILINGSTOP)
                 OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point*TRAILINGSTOP, OrderTakeProfit(), 0, Blue);
      }
      else if(OrderType() == OP_SELL)
      {
         if(TRAILINGSTOP > 0)
            if(Ask + OrderOpenPrice() < Point * TRAILINGSTOP)
              if(OrderStopLoss()>Ask + Point * TRAILINGSTOP)
                 OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TRAILINGSTOP, OrderTakeProfit(), 0, Red);
      }
   }
}