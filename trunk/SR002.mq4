//+------------------------------------------------------------------+
//|                                              SuperWoodiesCCI.mq4 |
//|                                                           duckfu |
//|                                          http://www.dopeness.org |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      ""

#define  MAGICMA           0
#define  indicator         "Bands"

string   SYMBOL            = "EURUSD";
int      TIMEFRAME         = 0;
int      MAXORDERS         = 1;

//int      TRADINGDAYHOURS[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};
int      TRADINGDAYHOURS[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};
//int      TRADINGDAYHOURS[] = {14, 15, 16, 17, 18, 19, 20, 21, 22};
//int      TRADINGDAYHOURS[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 18, 19, 20, 21, 22, 23};

//Expert Settings
double   MINLOTS           = 0.1;
double   MAXLOTS           = 5;
double   MAXIMUMRISK       = 0.1;
int      SLIPPAGE          = 3;

double   STOPLOSS          = 10;
double   TRAILINGSTOP      = 0;
double   TAKEPROFIT        = 0;

int      PERIOD            = 0.02;


//Globals
datetime LastBarTraded     = 0;
int      LastPSARPosition  = 0;
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
   CheckForClosePositions();   
   CheckForModifyPositions();
   if(TradeAllowed())
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
   if(!IsTradingHour())
   {
      CloseAllPositions();
      return(false);
   }
   return(true);
}

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
//+------------------------------------------------------------------+
//| Get amount of lots to trade                                      |
//+------------------------------------------------------------------+
double GetLots()
{
   double lot;
   lot = NormalizeDouble(AccountFreeMargin() * MAXIMUMRISK / 1000.0, 1);
   if(lot < MINLOTS)
      lot = 0;
   else if(lot > MAXLOTS)
      lot = MAXLOTS;
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
   
/*
   return(result);

   int i, result = 0;

   double  MA20, MA34, CCI, PSAR1, PSAR2;

//   CCI = iCCI(SYMBOL, TIMEFRAME, 50, PRICE_CLOSE, 1);
//   MA20 = iMA(SYMBOL, TIMEFRAME, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
//   MA34 = iMA(SYMBOL, TIMEFRAME, 34, 0, MODE_SMA, PRICE_CLOSE, 1);
   PSAR1 = iSAR(SYMBOL, TIMEFRAME, 0.05, 20, 1);
   PSAR2 = iSAR(SYMBOL, TIMEFRAME, 0.05, 20, 2);

   if(PSAR1 > Bid && LastPSARPosition <= 0)
   {
      result = -1;
      LastPSARPosition = 1;
   }
   if(PSAR1 < Ask && LastPSARPosition >= 0)
   {
      result = 1;
      LastPSARPosition = -1;
   }

/*
   if(PSAR2 > Bid && PSAR1 > Bid)
   {
      result = -1;
   }
   if(PSAR2 < Ask && PSAR1 < Ask)
   {
      result = 1;
   }
*/
/*
   if(PSAR > High[1])
      result = -1;
   if(PSAR < Low[1])
      result = 1;
*/

//----
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
}
//
void ClosePositions(int OrderTickets2Close[])
{
   int i;
   
   for(i = 0; i < ArraySize(OrderTickets2Close); i++)
   {
      OrderSelect(OrderTickets2Close[i], SELECT_BY_TICKET);
      if(OrderType() == OP_SELL)
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, Orange);
      else if(OrderType() == OP_BUY)
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, Orange);
   }
}
//
void CloseAllPositions()
{
   int i;
   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);
   
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      ArrayResize(OrderTickets2Close, i + 1);
      OrderTickets2Close[i] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//+------------------------------------------------------------------------------------+
//| Closes position based on indicator state                                           |
//+------------------------------------------------------------------------------------+
void CheckForClosePositions()
{
   int i, j;
   bool closebuy = false, closesell = false;

   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);
   
   double  MA20, MA34, CCI, PSAR, MacdDiff1;

//   CCI = iCCI(SYMBOL, TIMEFRAME, 50, PRICE_CLOSE, 1);
   MA20 = iMA(SYMBOL, TIMEFRAME, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
//   MA34 = iMA(SYMBOL, TIMEFRAME, 34, 0, MODE_SMA, PRICE_CLOSE, 1);
   PSAR = iSAR(SYMBOL, TIMEFRAME, 0.05, 20, 1);
//   MacdDiff1 = iCustom(SYMBOL, TIMEFRAME, "MACD+HistogramDiff+SignalDiff", 10, 20, 9, 2, 1);

   if(PSAR > Bid)
      closebuy = true;      
   if(PSAR < Ask)
      closesell = true;


   if(PSAR > MA20)
      closebuy = true;      
   if(PSAR < MA20)
      closesell = true;

/*
   if(MacdDiff1 < 0)
      closebuy = true;      
   if(MacdDiff1 > 0)
      closesell = true;
*/

   j = 0;
   if(closebuy)
      for(i = 0; i < OrdersTotal(); i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderType() == OP_BUY && OrderComment() != TimeToStr(Time[0]))
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
      }
   if(closesell)
      for(i = 0; i < OrdersTotal(); i++)
      {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderType() == OP_SELL && OrderComment() != TimeToStr(Time[0]))
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
      }
   
   ClosePositions(OrderTickets2Close);
   
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