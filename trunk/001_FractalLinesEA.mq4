#property copyright "slacktrader"
#property link      ""

#define  MAGICMA           0

int      MAXORDERS         = 1;

int      TRADINGDAYHOURS[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};

//Expert Settings
double   FIXLOT            = 0.1;      //if 0, uses maximumrisk, else uses only this while trading
double   MINLOTS           = 0.1;      //minimum lot
double   MAXLOTS           = 5;        //maximum lot
double   MAXIMUMRISK       = 0.05;     //maximum risk, if FIXLOT = 0
int      SLIPPAGE          = 3;        //max slippage alowed

double   STOPLOSS          = 0;       //SL
double   TRAILINGSTOP      = 0;        //
double   TAKEPROFIT        = 0;       //TP

//Number of bars, to see what a stop level should be used
// 0 - menas not use this SL technique
int      NBarsBackStop     = 1;
//Amount of points to put SL above High/Low of N-th Bars
int      NPipsOverSL       = 0;
//Amount of points from Fractal HL to get a trade - to avoid line touches 
int      NPipsOverHL       = 2;

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
//   if(LastBarTraded == Time[0])
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
   double lot, result;
   if(FIXLOT == 0)
      lot = NormalizeDouble(AccountFreeMargin() * MAXIMUMRISK / 1000.0, 1);
   else
      lot = FIXLOT;

   if(lot > AccountFreeMargin() / 1500.0)
      lot = MathFloor(10 * AccountFreeMargin() / 1500.0)/ 10;

   if(lot < MINLOTS)
      lot = MINLOTS;
   else if(lot > MAXLOTS)
      lot = MAXLOTS;
      
   return(lot);
}
//+------------------------------------------------------------------+
//| Checks of open short, long or nothing (-1, 1, 0)                 |
//+------------------------------------------------------------------+
int CheckForOpenPosition()
{
   int result = 0;
   double UpperFractalHL = iCustom(NULL, 0, "FractalsLine", 0, 0, 0);
   double LowerFractalHL = iCustom(NULL, 0, "FractalsLine", 0, 1, 0);
   
   if(Ask > UpperFractalHL + NPipsOverHL*Point && Low[0] < UpperFractalHL)
      result = 1;
   if(Bid < LowerFractalHL - NPipsOverHL*Point && High[0] > LowerFractalHL)
      result = -1;

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
      if(NBarsBackStop != 0)
      {
         SL = High[NBarsBackStop] + NPipsOverSL * Point;
         if(SL < Bid + 10)
            SL = Bid + 10;
      }
      else if(STOPLOSS != 0)
         SL = Bid + STOPLOSS * Point;
      else
         SL = 0;
      if(TAKEPROFIT != 0)
         TP = Bid - TAKEPROFIT * Point;
      else
         TP = 0;
      OrderSend(Symbol(), OP_SELL, Lots, Bid, SLIPPAGE, SL, TP, TimeToStr(Time[0]), MAGICMA, 0, Red);
   }
   else if(ShortLong == 1)
   {
      if(NBarsBackStop != 0)
      {
         SL = Low[NBarsBackStop] - NPipsOverSL * Point;
         if(SL < Ask - 10)
            SL = Ask - 10;
      }
      else if(STOPLOSS != 0)
         SL = Ask - STOPLOSS * Point;
      else
         SL = 0;
      if(TAKEPROFIT != 0)
         TP = Ask + TAKEPROFIT * Point;
      else
         TP = 0;
      OrderSend(Symbol(), OP_BUY, Lots, Ask, SLIPPAGE, SL, TP, TimeToStr(Time[0]), MAGICMA, 0, Blue);
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
   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);

   double UpperFractalHL = iCustom(NULL, 0, "FractalsLine", 0, 0, 0);
   double LowerFractalHL = iCustom(NULL, 0, "FractalsLine", 0, 1, 0);
   double MacdDiff1 = iCustom(NULL, 0, "MACD+HistogramDiff+SignalDiff", 10, 20, 9, 2, 1);
   double MA20 = iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
   double PSAR = iSAR(NULL, 0, 0.05, 20, 1);

   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderType() == OP_BUY)
         if(
         Bid < LowerFractalHL
          || 
/*
         (Bid < UpperFractalHL && Low[1] > UpperFractalHL)
          || 
*/
/*
         (Low[1] > LowerFractalHL)
          ||
         (High[1] < UpperFractalHL)
*/
/*
          ||
*/
//         (MacdDiff1 < 0)
         (High[2] > High[1] && High[2] > OrderOpenPrice())
/*
          ||
         (PSAR > Bid)
          ||
         (PSAR > MA20)
*/
         )
         {
            ArrayResize(OrderTickets2Close, j + 1);
            OrderTickets2Close[i] = OrderTicket();
            j++;
         }
   }
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderType() == OP_SELL)
         if(
         Ask > UpperFractalHL
          || 
/*
         (Ask > LowerFractalHL && High[1] < LowerFractalHL)
          || 
*/
/*
         (High[1] < UpperFractalHL)
          ||
         (Low[1] > LowerFractalHL)
*/
/*
          ||
*/
//         (MacdDiff1 > 0)
         (Low[2] < Low[1] && Low[2] < OrderOpenPrice())
/*
          ||
         (PSAR < Ask)
          ||
         (PSAR < MA20)
*/
         )
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
      if(OrderMagicNumber() != MAGICMA)
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