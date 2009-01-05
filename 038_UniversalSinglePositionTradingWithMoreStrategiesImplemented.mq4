#property copyright "slacktrader"
#property link      "slacktrader"

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// main variables                                                         
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
int   _ALL_STRATEGIES                  = 22;
int   _ACTIVE_STRATEGIES[]             = {21,22};

int   _MIN_STOPLOSS_DISTANCE           = 10;
int   _MIN_TAKEPROFIT_DISTANCE         = 15;

// 1 - PERIOD_M1
// 2 - PERIOD_M5
// 3 - PERIOD_M15
// 4 - PERIOD_M30
// 5 - PERIOD_H1
// 6 - PERIOD_H4
// 7 - PERIOD_D1
// 8 - PERIOD_W1
// 9 - PERIOD_MN1

// _STRATEGY_TIMEFRAME_CHOICE
//extern string poznamka1 = "0 - vyber timeframe podla dropdown menu - premenna _STRATEGY_TIMEFRAME sa ignoruje";
//extern string poznamka2 = "1 - vyber timeframe podla kodu timeframe 1 - 9";
int     _STRATEGY_TIMEFRAME_CHOICE    = 0;
int     _STRATEGY_TIMEFRAME           = 1;

int     _SIGNAL_COMBINATION           = 1;

//string poznamka1 = "0 - vyber timeframe podla dropdown menu - premenna _STRATEGY_TIMEFRAME sa ignoruje";
//string poznamka2 = "1 - vyber timeframe podla kodu timeframe 1 - 9";
//int   _STRATEGY_TIMEFRAME_CHOICE    = 1;
//int   _STRATEGY_TIMEFRAME           = 1;

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// MM Modul                                                         
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
#define     _MM_FIX_LOT                         1
#define     _MM_FIX_PERC                        2
#define     _MM_FIX_PERC_AVG_LAST_PROFIT        3
#define     _MM_FIX_PERC_CNT_MAX_DD             4

#define     _MINLOTS                            0.1
#define     _MAXLOTS                            5
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// Signal Modul                                                     
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
#define     _OPEN_LONG                    1
#define     _OPEN_SHORT                   2
#define     _CLOSE_LONG                   3
#define     _CLOSE_SHORT                  4
#define     _GET_LONG_STOPLOSS_PRICE      5
#define     _GET_SHORT_STOPLOSS_PRICE     6
#define     _GET_LONG_TAKEPROFIT_PRICE    7
#define     _GET_SHORT_TAKEPROFIT_PRICE   8
#define     _GET_LOTS                     9
#define     _GET_TRAILED_STOPLOSS_PRICE   10
#define     _GET_TRAILED_TAKEPROFIT_PRICE 11
#define     _GET_TRADED_TIMEFRAME         12
#define     _OPEN_PENDING_BUY_STOP        13
#define     _OPEN_PENDING_SELL_STOP       14
#define     _OPEN_PENDING_BUY_LIMIT       15
#define     _OPEN_PENDING_SELL_LIMIT      16
#define     _GET_PENDING_BUY_STOP_PRICE   17
#define     _GET_PENDING_SELL_STOP_PRICE  18
#define     _GET_PENDING_ORDER_EXPIRATION 19
#define     _GET_STRATEGY_NUMBER          20
#define     _GET_STRATEGY_MAGICNUMBER     21
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
static datetime LastBarTraded = 0;

int   LONGMA = 140;
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
int init()
{
   return(0);
}
int deinit()
{
   
   return(0);
}

int start()
{
   double            Stoploss          = 0;
   double            TakeProfit        = 0;
   int               OrderTickets[];
   int               i, j, k;

   ArrayResize(OrderTickets, 0);
   
   if(LastBarTraded())
      return(0);
   
//Get all openned orders and their magicnumber   
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      ArrayResize(OrderTickets, ArraySize(OrderTickets) + 1);
      OrderTickets[ArraySize(OrderTickets) - 1] = OrderTicket();
   }

//iterate all strategies and choose only active ones
   for(i = 0; i < _ALL_STRATEGIES; i++)
   {
//iterate all active strategies and aply strategy on order if magicnumbers are equal
      for(j = 0; j < ArraySize(_ACTIVE_STRATEGIES); j++)
      {
         if(Strategy(i, _GET_STRATEGY_NUMBER) != _ACTIVE_STRATEGIES[j])
            continue;

         for(k = 0; k < ArraySize(OrderTickets); k++)
         {
            OrderSelect(OrderTickets[k], SELECT_BY_TICKET);
         
            if(OrderMagicNumber() != Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER))
               continue;
         
            Stoploss = Strategy(_ACTIVE_STRATEGIES[j], _GET_TRAILED_STOPLOSS_PRICE);
            TakeProfit = Strategy(_ACTIVE_STRATEGIES[j], _GET_TRAILED_TAKEPROFIT_PRICE);

            if(Stoploss != 0 || TakeProfit != 0)
               ModifyAllPositions(OrderMagicNumber(), Stoploss, TakeProfit);

            if(Strategy(_ACTIVE_STRATEGIES[j], _CLOSE_LONG) == 1)
               CloseAllLongPositions(OrderMagicNumber());
            if(Strategy(_ACTIVE_STRATEGIES[j], _CLOSE_SHORT) == 1)
               CloseAllShortPositions(OrderMagicNumber());
         }
      }
   }
      
   if(!TradeAllowed(1))
      return(0);

//iterate all strategies and choose only active ones
   for(i = 0; i < _ALL_STRATEGIES; i++)
   {
      bool OrderExists = false;
//iterate all active strategies and aply strategy on order if magicnumbers are equal

      for(j = 0; j < ArraySize(_ACTIVE_STRATEGIES); j++)
      {
         if(Strategy(i, _GET_STRATEGY_NUMBER) != _ACTIVE_STRATEGIES[j])
            continue;

//if order for this strategy already exists - do not chech this strategy for open         
         for(k = 0; k < OrdersTotal(); k++)
         {
            OrderSelect(k, SELECT_BY_POS);
            if(OrderMagicNumber() == Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER))
            {
               OrderExists = true;
               break;
            }
         }
         
         if(!OrderExists)
         {
            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_LONG) == 1)
               OpenPosition(false, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER));
            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_SHORT) == 1)
               OpenPosition(true, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER));

            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_PENDING_BUY_STOP) == 1)
               OpenPendingPosition(false, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_BUY_STOP_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_LONG_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_ORDER_EXPIRATION));
            if(Strategy(_ACTIVE_STRATEGIES[j], _OPEN_PENDING_SELL_STOP) == 1)
               OpenPendingPosition(true, Strategy(_ACTIVE_STRATEGIES[j], _GET_LOTS), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_SELL_STOP_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_STOPLOSS_PRICE), Strategy(_ACTIVE_STRATEGIES[j], _GET_SHORT_TAKEPROFIT_PRICE), 3, Strategy(_ACTIVE_STRATEGIES[j], _GET_STRATEGY_MAGICNUMBER), Strategy(_ACTIVE_STRATEGIES[j], _GET_PENDING_ORDER_EXPIRATION));
         }

      }
   }

   return(0);
}
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// Trading allowed modul
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------

//------------------------------------------------------------------
// Last bar already traded
//------------------------------------------------------------------
bool LastBarTraded()
{
//Trade only once on each bar
   if(LastBarTraded == Time[0])
      return(true);
   else
      return(false);
}
//------------------------------------------------------------------
// First tick of a traded timeframe bar
//------------------------------------------------------------------
bool OpenNewBar(int _TIMEFRAME)
{
   if(iVolume(Symbol(), _TIMEFRAME, 0) > 1)
      return(false);
   else
      return(true);
}
//------------------------------------------------------------------
// TradeAllowed function return true if trading is possible         
//------------------------------------------------------------------
bool TradeAllowed(int MAXORDERS)
{
//Trade only once on each bar
   if(!IsTradeAllowed()) 
      return(false);
//   if(OrdersTotal() >= MAXORDERS)
//      return(false);
   return(true);
}

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// MM Modul                                                         
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
double GetLots(int MM_STRATEGY, int AMOUNT)
{
   double lot, result;

   switch(MM_STRATEGY)
   {
      case _MM_FIX_LOT:
      {
         lot = AMOUNT;

         break;
      }
      case _MM_FIX_PERC:
      {
         lot = NormalizeDouble(AccountFreeMargin() * AMOUNT / 1000.0, 1);

         break;
      }
      case _MM_FIX_PERC_AVG_LAST_PROFIT:
      {
         lot = NormalizeDouble(AccountFreeMargin() * AMOUNT / 1000.0, 1);

         break;
      }
   }

//   if(lot > AccountFreeMargin() / 1500.0)
//      lot = MathFloor(10 * AccountFreeMargin() / 1500.0)/ 10;

   if(lot < _MINLOTS)
      lot = _MINLOTS;
   else if(lot > _MAXLOTS)
      lot = _MAXLOTS;
      
   return(lot);
}
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// Order open modul
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------

//------------------------------------------------------------------------------------
// Opens position according to arguments (short || long, amount of Lots to trade 
//------------------------------------------------------------------------------------
void OpenPosition(bool SHORTLONG, double LOTS, double STOPLOSS, double TAKEPROFIT, int SLIPPAGE, int MAGICNUMBER)
{
   if(SHORTLONG)
   {
      OrderSend(Symbol(), OP_SELL, LOTS, Bid, SLIPPAGE, STOPLOSS, TAKEPROFIT, StringConcatenate(MAGICNUMBER, ""), MAGICNUMBER, 0, Red);
   }
   else
   {
      OrderSend(Symbol(), OP_BUY, LOTS, Ask, SLIPPAGE, STOPLOSS, TAKEPROFIT, StringConcatenate(MAGICNUMBER, ""), MAGICNUMBER, 0, Blue);
   }
   
   LastBarTraded = Time[0];
}
//------------------------------------------------------------------------------------
// Opens pending position according to arguments (sell stop || buy stop, amount of Lots to trade 
//------------------------------------------------------------------------------------
void OpenPendingPosition(bool SHORTLONG, double LOTS, double OPENPRICE, double STOPLOSS, double TAKEPROFIT, int SLIPPAGE, int MAGICNUMBER, datetime EXPIRATION)
{
   if(SHORTLONG)
   {
      OrderSend(Symbol(), OP_SELLSTOP, LOTS, OPENPRICE, SLIPPAGE, STOPLOSS, TAKEPROFIT, StringConcatenate(MAGICNUMBER, ""), MAGICNUMBER, EXPIRATION, Red);
   }
   else
   {
      OrderSend(Symbol(), OP_BUYSTOP, LOTS, OPENPRICE, SLIPPAGE, STOPLOSS, TAKEPROFIT, StringConcatenate(MAGICNUMBER, ""), MAGICNUMBER, EXPIRATION, Blue);
   }
   
   LastBarTraded = Time[0];
}
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//Position controll modul
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
void ModifyAllPositions(int MAGICNUMBER, double STOPLOSS, double TAKEPROFIT)
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         break;
      if(OrderMagicNumber() != MAGICNUMBER)
         continue;
      
      ModifyPosition(OrderTicket(), STOPLOSS, TAKEPROFIT);
   }
}
//------------------------------------------------------------------------------------
void ModifyPosition(int TICKETNUMBER, double STOPLOSS, double TAKEPROFIT)
{
   STOPLOSS = NormalizeDouble(STOPLOSS, 4);
   TAKEPROFIT = NormalizeDouble(TAKEPROFIT, 4);
   
   OrderSelect(TICKETNUMBER, SELECT_BY_TICKET);
   if(NormalizeDouble(OrderStopLoss(), 4) == NormalizeDouble(STOPLOSS, 4) && NormalizeDouble(OrderTakeProfit(), 4) == NormalizeDouble(TAKEPROFIT, 4))
      return;

//check minimal distance of STOPLOSS and TAKEPROFIT and if are not met - correct SL and TP values to minimal values and print message into LOG file
   if(OrderType() == OP_BUY)
   {
      if(Bid - _MIN_STOPLOSS_DISTANCE*Point < STOPLOSS)
      {
         Print("Bad OrderModify() STOPLOSS defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Bid was: ", Bid, " and STOPLOSS was: ", STOPLOSS, " . STOPLOSS set to minimal value: ", Bid - _MIN_STOPLOSS_DISTANCE*Point);
         STOPLOSS = Bid - _MIN_STOPLOSS_DISTANCE*Point;
      }
      if(Bid + _MIN_TAKEPROFIT_DISTANCE*Point > TAKEPROFIT)
      {
         Print("Bad OrderModify() TAKEPROFIT defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Bid was: ", Bid, " and TAKEPROFIT was: ", TAKEPROFIT, " . TAKEPROFIT set to minimal value: ", Bid + _MIN_TAKEPROFIT_DISTANCE*Point);
         TAKEPROFIT = Bid + _MIN_TAKEPROFIT_DISTANCE*Point;
      }
   }
   if(OrderType() == OP_SELL)
   {
      if(Ask + _MIN_STOPLOSS_DISTANCE*Point > STOPLOSS)
      {
         Print("Bad OrderModify() STOPLOSS defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Ask was: ", Ask, " and STOPLOSS was: ", STOPLOSS, " . STOPLOSS set to minimal value: ", Ask + _MIN_STOPLOSS_DISTANCE*Point);
         STOPLOSS = Ask + _MIN_STOPLOSS_DISTANCE*Point;
      }
      if(Ask - _MIN_TAKEPROFIT_DISTANCE*Point < TAKEPROFIT)
      {
         Print("Bad OrderModify() TAKEPROFIT defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Ask was: ", Ask, " and TAKEPROFIT was: ", TAKEPROFIT, " . TAKEPROFIT set to minimal value: ", Ask - _MIN_TAKEPROFIT_DISTANCE*Point);
         TAKEPROFIT = Ask - _MIN_TAKEPROFIT_DISTANCE*Point;
      }
   }
   
//   Print(Ask, " - ", Bid, " - ", OrderTicket(), " - ", OrderOpenPrice(), " - ", OrderStopLoss(), " - ", OrderTakeProfit(), " - ", STOPLOSS, " - ", TAKEPROFIT, " - ", OrderMagicNumber());
   OrderModify(OrderTicket(), OrderOpenPrice(), STOPLOSS, TAKEPROFIT, 0);
}
//------------------------------------------------------------------------------------
// Close all positions
//------------------------------------------------------------------------------------
void CloseAllPositions(int MAGICNUMBER)
{
   int i;
   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);
   
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderMagicNumber() != MAGICNUMBER)
         continue;
      ArrayResize(OrderTickets2Close, ArraySize(OrderTickets2Close) + 1);
      OrderTickets2Close[ArraySize(OrderTickets2Close) - 1] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//------------------------------------------------------------------------------------
// Close all long positions
//------------------------------------------------------------------------------------
void CloseAllLongPositions(int MAGICNUMBER)
{
   int i;
   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);
   
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderMagicNumber() != MAGICNUMBER || OrderType() != OP_BUY)
         continue;
      ArrayResize(OrderTickets2Close, ArraySize(OrderTickets2Close) + 1);
      OrderTickets2Close[ArraySize(OrderTickets2Close) - 1] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//------------------------------------------------------------------------------------
// Close all short positions
//------------------------------------------------------------------------------------
void CloseAllShortPositions(int MAGICNUMBER)
{
   int i;
   int OrderTickets2Close[];
   ArrayResize(OrderTickets2Close, 0);
   
   for(i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderMagicNumber() != MAGICNUMBER || OrderType() != OP_SELL)
         continue;
      ArrayResize(OrderTickets2Close, ArraySize(OrderTickets2Close) + 1);
      OrderTickets2Close[ArraySize(OrderTickets2Close) - 1] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//------------------------------------------------------------------------------------
// Close positions by ticket array
//------------------------------------------------------------------------------------
void ClosePositions(int OrderTickets2Close[])
{
   int i;
   
   for(i = 0; i < ArraySize(OrderTickets2Close); i++)
   {
      ClosePosition(OrderTickets2Close[i]);
   }
}
//------------------------------------------------------------------------------------
// Close position by ticket
//------------------------------------------------------------------------------------
void ClosePosition(int OrderTicket2Close)
{
   if(OrderSelect(OrderTicket2Close, SELECT_BY_TICKET))
   {
      if(OrderType() == OP_SELL)
         OrderClose(OrderTicket(), OrderLots(), Ask, 3, Orange);
      else if(OrderType() == OP_BUY)
         OrderClose(OrderTicket(), OrderLots(), Bid, 3, Orange);
   }
}
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// Tools - rozne
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//
string getStrategyCurrencyByNumber(int _CURRENCY)
{
// 1  - EURUSD
// 2  - GBPUSD
// 3  - USDCHF
// 4  - USDJPY
// 5  - EURJPY
// 6  - EURCHF
// 7  - EURGBP
// 8  - GBPJPY
// 9  - CHFJPY
// 10 - GBPCHF
   switch(_CURRENCY)
   {
      case 1:
         return ("EURUSD");
      case 2:
         return ("GBPUSD");
      case 3:
         return ("USDCHF");
      case 4:
         return ("USDJPY");
      case 5:
         return ("EURJPY");
      case 6:
         return ("EURCHF");
      case 7:
         return ("EURGBP");
      case 8:
         return ("GBPJPY");
      case 9:
         return ("CHFJPY");
      case 10:
         return ("GBPCHF");
   }
}
//------------------------------------------------------------------
int getStrategyTimeframeByNumber(int _PERIOD)
{
// 1 - PERIOD_M1
// 2 - PERIOD_M5
// 3 - PERIOD_M15
// 4 - PERIOD_M30
// 5 - PERIOD_H1
// 6 - PERIOD_H4
// 7 - PERIOD_D1
// 8 - PERIOD_W1
// 9 - PERIOD_MN1
   if(_STRATEGY_TIMEFRAME_CHOICE == 0)
      return(Period());
   else
      switch(_PERIOD)
      {
         case 1:
            return (PERIOD_M1);
         case 2:
            return (PERIOD_M5);
         case 3:
            return (PERIOD_M15);
         case 4:
            return (PERIOD_M30);
         case 5:
            return (PERIOD_H1);
         case 6:
            return (PERIOD_H4);
         case 7:
            return (PERIOD_D1);
         case 8:
            return (PERIOD_W1);
         case 9:
            return (PERIOD_MN1);
      }
}
//------------------------------------------------------------------
int HigherTimeframe(int Timeframe)
{
   switch(Timeframe)
   {
      case PERIOD_M1:
         return (PERIOD_M5);
      case PERIOD_M5:
         return (PERIOD_M15);
      case PERIOD_M15:
         return (PERIOD_M30);
      case PERIOD_M30:
         return (PERIOD_H1);
      case PERIOD_H1:
         return (PERIOD_H4);
      case PERIOD_H4:
         return (PERIOD_D1);
      case PERIOD_D1:
         return (PERIOD_W1);
      case PERIOD_W1:
         return (PERIOD_MN1);
   }
   
   return (Timeframe);
}
//------------------------------------------------------------------------------------
// FRACTALS
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
// Last fractal value
//------------------------------------------------------------------------------------
datetime getLastFractalTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalTime(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous fractal value
//------------------------------------------------------------------------------------
datetime getPreviousFractalTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalTime(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// Last fractal value
//------------------------------------------------------------------------------------
double getLastFractalValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalValue(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous fractal value
//------------------------------------------------------------------------------------
double getPreviousFractalValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthFractalValue(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// NthFractal fractal value
//------------------------------------------------------------------------------------
double getNthFractalValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   double   result      = 0;
   int      i           = 0;
   int      NthFractal  = Nth;     // NthFractal - put here number of fractal into history you want to get a value for
      
   if(UpperLower)
   {
      while(i < 1000 && NthFractal > 0)
      {
         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, i);
         
         i++;
         if(result > 0)
         {
            NthFractal--;
            continue;
         }
      }
   }
   else
   {
      while(i < 1000 && NthFractal > 0)
      {
         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, i);

         i++;
         if(result > 0)
         {
            NthFractal--;
            continue;
         }
      }
   }
   
   return (result);
}
//------------------------------------------------------------------------------------
// NthFractal fractal time
//------------------------------------------------------------------------------------
datetime getNthFractalTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   datetime result      = 0;
   int      i           = 0;
   int      NthFractal  = Nth;     // NthFractal - put here number of fractal into history you want to get a value for
      
   if(UpperLower)
   {
      while(i < 1000 && NthFractal > 0)
      {
         i++;
         if(iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, i) > 0)
         {
            NthFractal--;
            continue;
         }
      }
      
      return(iTime(_SYMBOL, _TIMEFRAME, i));
   }
   else
   {
      while(i < 1000 && NthFractal > 0)
      {
         i++;
         if(iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, i) > 0)
         {
            NthFractal--;
            continue;
         }
      }

      return(iTime(_SYMBOL, _TIMEFRAME, i));
   }
   
   return (result);
}
//------------------------------------------------------------------------------------
// ZIGZAG
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
// Last ZIGZAG time
//------------------------------------------------------------------------------------
datetime getLastZIGZAGTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGTime(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous ZIGZAG time
//------------------------------------------------------------------------------------
datetime getPreviousZIGZAGTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGTime(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// Last ZIGZAG value
//------------------------------------------------------------------------------------
double getLastZIGZAGValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGValue(_SYMBOL, _TIMEFRAME, UpperLower, 1));
}
//------------------------------------------------------------------------------------
// Previous ZIGZAG value
//------------------------------------------------------------------------------------
double getPreviousZIGZAGValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower)
{
   return (getNthZIGZAGValue(_SYMBOL, _TIMEFRAME, UpperLower, 2));
}
//------------------------------------------------------------------------------------
// Nth ZIGZAG value
//------------------------------------------------------------------------------------
double getNthZIGZAGValue(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   double   result      = 0;
   int      i           = 0;
   int      NthZIGZAG   = 2*Nth + 1;
   double   ZIGZAG1     = 0;
   double   ZIGZAG2     = 0;
   
   while(i < 1000 && NthZIGZAG > 0)
   {
      result = iCustom(_SYMBOL, _TIMEFRAME, "ZigZag", 12, 5, 3, 0, i);
                 
      i++;

      if(result > 0)
      {
         ZIGZAG1 = ZIGZAG2;
         ZIGZAG2 = result;
         NthZIGZAG--;
         continue;
      }
   }
   
   if(UpperLower)
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG1;
      else
         result = ZIGZAG2;
   }
   else
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG2;
      else
         result = ZIGZAG1;
   }
   
   return (result);
}
//------------------------------------------------------------------------------------
// Nth ZIGZAG time
//------------------------------------------------------------------------------------
datetime getNthZIGZAGTime(string _SYMBOL, int _TIMEFRAME, bool UpperLower, int Nth)
{
   double   result      = 0;
   int      i           = 0;
   int      NthZIGZAG   = 2*Nth + 1;
   double   ZIGZAG1     = 0;
   double   ZIGZAG2     = 0;
   int      ZIGZAG1Time = 0;
   int      ZIGZAG2Time = 0;
   
   while(i < 1000 && NthZIGZAG > 0)
   {
      result = iCustom(_SYMBOL, _TIMEFRAME, "ZigZag", 12, 5, 3, 0, i);
      
      i++;

      if(result > 0)
      {
         ZIGZAG1 = ZIGZAG2;
         ZIGZAG2 = result;
         ZIGZAG1Time = ZIGZAG2Time;
         ZIGZAG2Time = i - 1;
         NthZIGZAG--;
         continue;
      }
   }
   
   if(UpperLower)
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG1Time;
      else
         result = ZIGZAG2Time;
   }
   else
   {
      if(ZIGZAG1 > ZIGZAG2)
         result = ZIGZAG2Time;
      else
         result = ZIGZAG1Time;
   }
   
   return(iTime(_SYMBOL, _TIMEFRAME, result));
}
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//Signal modul
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
//
double Strategy(int _STRATEGY, int _COMMAND)
{
// Ide o MACD strategiu, kde sa ako vstupne signaly vyhodnocuju MACD z dvoch TIMEFRAME
// V podstate je mozne kombinovat tuto logiku rozne a aplikovat nezavisle na vstupy a vystupy
   if(_STRATEGY == Strategy_001(_GET_STRATEGY_NUMBER))
      return(Strategy_001(_COMMAND));
// Ide o MACD strategiu, kde sa ako vstupne a vystupne signaly vyhodnocuje MACD iba z jedneho TIMEFRAME - trailng stop
// pomocou LOW/HIGH predch. baru o adaptivnej velkosti podla prveho SL
   if(_STRATEGY == Strategy_002(_GET_STRATEGY_NUMBER))
      return(Strategy_002(_COMMAND));
// Ide o MACD strategiu, kde sa ako vstupne a vystupne signaly vyhodnocuje MACD iba z jedneho TIMEFRAME - trailng stop
// pomocou LOW/HIGH predch. baru o adaptivnej velkosti podla prveho SL - rozne vstupne strategie za ucelom zvysenia efektivity
   if(_STRATEGY == Strategy_003(_GET_STRATEGY_NUMBER))
      return(Strategy_003(_COMMAND));
// Ide o MACD strategiu, kde sa ako vstupne signaly vyhodnocuje MACD iba z jedneho TIMEFRAME - trailng stop
// pomocou LOW/HIGH predch. baru o adaptivnej velkosti podla prveho SL - rozne vystupne strategie za ucelom zvysenia efektivity
   if(_STRATEGY == Strategy_004(_GET_STRATEGY_NUMBER))
      return(Strategy_004(_COMMAND));
// Ide o strategiu zachytenia trendu nestandardnymi metodami na urovni sviecok, prerazeni, naslednych neustale stupajucich/klesajucich  open/close atd
// vystupy su taktiez riadene podobnymi metodami 
   if(_STRATEGY == Strategy_005(_GET_STRATEGY_NUMBER))
      return(Strategy_005(_COMMAND));
// Ide o strategiu dvoch MA s blizkou periodou - otvorenie/uzavretie pozicie pri prekrizeni dvoch MA
// Podporena je dlhym MA - ak je cena nad iba kupovat a opacne
// este su vstupy filtrovane pomocou MACD
   if(_STRATEGY == Strategy_006(_GET_STRATEGY_NUMBER))
      return(Strategy_006(_COMMAND));
// Strategia vstupov len pri prekrizeni
   if(_STRATEGY == Strategy_007(_GET_STRATEGY_NUMBER))
      return(Strategy_007(_COMMAND));
// Strategia SL a trailing stop podla fractals
// rozne vstupne strategie - filtrovanie pomocou roznych technik
   if(_STRATEGY == Strategy_008(_GET_STRATEGY_NUMBER))
      return(Strategy_008(_COMMAND));
// kombinacie vstupov zo strategie 1 a stoploss zo strategie 8
   if(_STRATEGY == Strategy_009(_GET_STRATEGY_NUMBER))
      return(Strategy_009(_COMMAND));
// fraktaly pre vstup, stop trailing aj vystup
   if(_STRATEGY == Strategy_010(_GET_STRATEGY_NUMBER))
      return(Strategy_010(_COMMAND));
// 
   if(_STRATEGY == Strategy_011(_GET_STRATEGY_NUMBER))
      return(Strategy_011(_COMMAND));
// fraktaly - macd - support/resistance levels z rovnakych aj vyssich timeframes podporene macd
   if(_STRATEGY == Strategy_012(_GET_STRATEGY_NUMBER))
      return(Strategy_012(_COMMAND));
// pure macd neustale v trhu
   if(_STRATEGY == Strategy_013(_GET_STRATEGY_NUMBER))
      return(Strategy_013(_COMMAND));
// fraktaly ako smernice pre suuport a resistance a ich prerazenie
   if(_STRATEGY == Strategy_014(_GET_STRATEGY_NUMBER))
      return(Strategy_014(_COMMAND));
// denne sviecky - hladanie vnutornej sviecky - nerozhodnost trhu - umietnenie pending order nad/pod high/low vcerajsej sviecky a cakanie na prieraz
   if(_STRATEGY == Strategy_015(_GET_STRATEGY_NUMBER))
      return(Strategy_015(_COMMAND));
// modifikacia predosleho systemu - nie pending orders ale market, aby bolo mozne pouzit aj nizsie timeframes
   if(_STRATEGY == Strategy_016(_GET_STRATEGY_NUMBER))
      return(Strategy_016(_COMMAND));
// gap trading - medzi dnami/tyzdnami - gap sa zvykne zaplnit
// je dobre pockat na support - resistance aby sme mali pevny spodok - strop
   if(_STRATEGY == Strategy_017(_GET_STRATEGY_NUMBER))
      return(Strategy_017(_COMMAND));
// Malo by to byt o fraktaloch, resp. ZIGZAG indikatore
// tato strategia pracuje s uhlami, periodou a dlzkami ZIGZAG indikatora
   if(_STRATEGY == Strategy_018(_GET_STRATEGY_NUMBER))
      return(Strategy_018(_COMMAND));
// ZIGZAG + Bollinger Bands
// uhol spojnice ZIGZAG opacneho vrchola a dotycnice k BB - ak je vacsi -> place order
   if(_STRATEGY == Strategy_019(_GET_STRATEGY_NUMBER))
      return(Strategy_019(_COMMAND));
// ZIGZAG pokus na viacerych timeframe
   if(_STRATEGY == Strategy_020(_GET_STRATEGY_NUMBER))
      return(Strategy_020(_COMMAND));
// ZIGZAG spojnice vrcholov su supporty/resistance - ich prerazenie by malo vytvorit trend
   if(_STRATEGY == Strategy_021(_GET_STRATEGY_NUMBER))
      return(Strategy_021(_COMMAND));
// ZIGZAG spojnice vrcholov su supporty/resistance - odrazenie od nich je pravdepodobne
   if(_STRATEGY == Strategy_022(_GET_STRATEGY_NUMBER))
      return(Strategy_022(_COMMAND));

   return(0);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_001(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 1;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;
   
   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = PERIOD_H1;
   int      _TIMEFRAME_2   = PERIOD_H1;
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
// velmi dobre:
//   int      _SHIFT         = 2;
//   int      _PRICE         = PRICE_OPEN;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   double   MACDHistogram, MACDHistogram2;
   double   MACDSignal, MACDSignal2;
   
   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

// velmi dobre:
//         if(MACDHistogram > MACDSignal && MACDHistogram > 0)

//         if(MACDHistogram > MACDSignal && MACDHistogram2 > 0 && MACDSignal2 > 0 && MACDHistogram < 0 && MACDSignal < 0)
//         if(MACDHistogram > MACDSignal && MACDHistogram2 < MACDSignal2)
// celkom dobre
         if(MACDHistogram > MACDSignal && MACDHistogram2 < 0 && MACDSignal2 < 0)
//         if(MACDHistogram > MACDSignal && MACDHistogram2 > 0 && MACDSignal2 > 0 && MACDHistogram < 0)
//         if(MACDHistogram > MACDSignal && MACDHistogram2 > 0 && MACDSignal2 > 0)
            result = 1;
         
         break;
      }
      case _OPEN_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

// velmi dobre:
//         if(MACDHistogram < MACDSignal && MACDHistogram < 0)

//         if(MACDHistogram < MACDSignal && MACDHistogram2 < 0 && MACDSignal2 < 0 && MACDHistogram > 0 && MACDSignal > 0)
//         if(MACDHistogram < MACDSignal && MACDHistogram2 > MACDSignal2)
// celkom dobre
         if(MACDHistogram < MACDSignal && MACDHistogram2 > 0 && MACDSignal2 > 0)
//         if(MACDHistogram < MACDSignal && MACDHistogram2 < 0 && MACDSignal2 < 0 && MACDHistogram > 0)
//         if(MACDHistogram < MACDSignal && MACDHistogram2 < 0 && MACDSignal2 < 0)
            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0 && MACDSignal > 0)
//         if(MACDHistogram > 0 && MACDSignal > 0 && MACDHistogram < MACDSignal)
            result = 1;
         
         break;
      }
      case _CLOSE_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0 && MACDSignal < 0)
//         if(MACDHistogram < 0 && MACDSignal < 0 && MACDHistogram > MACDSignal)
            result = 1;

         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;
         
         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, 0);
         
         if(result > Ask - 10)
            result = 0;

         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         break;
         
         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, 0);
         
         if(result < Bid + 10)
            result = 0;
         
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;
         
         for(int i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
               else
                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
            }
         }
         
         break;
      }
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_002(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 2;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
// velmi dobre:
//   int      _SHIFT         = 2;
//   int      _PRICE         = PRICE_OPEN;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   double   MACDHistogram;
   double   MACDSignal;
   
   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

//         if(MACDHistogram > MACDSignal && MACDHistogram > 0)
         if(MACDHistogram > MACDSignal)
            result = 1;
         
         break;
      }
      case _OPEN_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

//         if(MACDHistogram < MACDSignal && MACDHistogram < 0)
         if(MACDHistogram < MACDSignal)
            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
//         if(MACDHistogram < 0)
//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0 && MACDSignal > 0)
//         if(MACDHistogram > 0 && MACDSignal > 0 && MACDHistogram < MACDSignal)
//            result = 1;
         
         break;
      }
      case _CLOSE_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
//         if(MACDHistogram > 0)
//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0 && MACDSignal < 0)
//         if(MACDHistogram < 0 && MACDSignal < 0 && MACDHistogram > MACDSignal)
//            result = 1;

         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, 1);
         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, 1);
         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         for(int i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
            
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  i = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());
                  
                  double Low1SL = iLow(_SYMBOL, _TIMEFRAME, 1);
                  double Low2SL = Bid - MathAbs(OrderOpenPrice() - iLow(_SYMBOL, _TIMEFRAME, i + 1));

                  if(Low1SL < Low2SL)
                     result = Low1SL;
                  else
                     result = Low2SL;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = 0;                  
               }
               else
               {
                  int j = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());

                  double High1SL = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  double High2SL = Ask + MathAbs(iHigh(_SYMBOL, _TIMEFRAME, j + 1) - OrderOpenPrice());
                  
                  if(High1SL > High2SL)
                     result = High1SL;
                  else
                     result = High2SL;
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                  if(result >= OrderStopLoss())
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_003(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 3;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
// velmi dobre:
//   int      _SHIFT         = 2;
//   int      _PRICE         = PRICE_OPEN;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   double   MACDHistogram;
   double   MACDSignal;
   
   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram > MACDSignal && MACDHistogram > 0)
//         if(MACDHistogram > MACDSignal && MACDHistogram < 0)
//         if(MACDHistogram > MACDSignal)
            result = 1;
         
         break;
      }
      case _OPEN_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram < MACDSignal && MACDHistogram < 0)
//         if(MACDHistogram < MACDSignal && MACDHistogram > 0)
//         if(MACDHistogram < MACDSignal)
            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
//         if(MACDHistogram < 0)
//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0 && MACDSignal > 0)
//         if(MACDHistogram > 0 && MACDSignal > 0 && MACDHistogram < MACDSignal)
//            result = 1;
         
         break;
      }
      case _CLOSE_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
//         if(MACDHistogram > 0)
//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0 && MACDSignal < 0)
//         if(MACDHistogram < 0 && MACDSignal < 0 && MACDHistogram > MACDSignal)
//            result = 1;

         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, 1);
         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, 1);
         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         for(int i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  i = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());
                  
                  double Low1SL = iLow(_SYMBOL, _TIMEFRAME, 1);
                  double Low2SL = Bid - MathAbs(OrderOpenPrice() - iLow(_SYMBOL, _TIMEFRAME, i + 1));

                  if(Low1SL < Low2SL)
                     result = Low1SL;
                  else
                     result = Low2SL;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = 0;
               }
               else
               {
                  int j = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());

                  double High1SL = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  double High2SL = Ask + MathAbs(iHigh(_SYMBOL, _TIMEFRAME, j + 1) - OrderOpenPrice());
                  
                  if(High1SL > High2SL)
                     result = High1SL;
                  else
                     result = High2SL;
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                  if(result >= OrderStopLoss())
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_004(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 4;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;

   double   MACDHistogram;
   double   MACDSignal;
      
   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram > MACDSignal && MACDHistogram < 0)
//         if(MACDHistogram > 0)
            result = 1;
         
         break;
      }
      case _OPEN_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram < MACDSignal && MACDHistogram > 0)
//         if(MACDHistogram < 0)
            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
   
         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram < 0)
            result = 1;
         
         break;
      }
      case _CLOSE_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         
         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram > 0)
            result = 1;

         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;
      }
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_005(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 5;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;

//   int      TIMEFRAME2 = _TIMEFRAME;
   int      TIMEFRAME2 = HigherTimeframe(_TIMEFRAME);
//   int      TIMEFRAME2 = HigherTimeframe(HigherTimeframe(_TIMEFRAME));

   double   MACDHistogram;
   double   MACDSignal;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MACDHistogram = iMACD(_SYMBOL, TIMEFRAME2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, TIMEFRAME2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
//         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
//         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram > MACDSignal && MACDHistogram < 0)
//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram > 0)
//         if(Open[0] > Open[1] && Open[1] > Open[2] && Open[2] > Open[3])
         if(Open[0] > Open[1] && Open[1] > Open[2])
//         if(Open[0] > Open[3])
         if(Open[0] > Low[1] && Low[1] > Low[2])
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
         MACDHistogram = iMACD(_SYMBOL, TIMEFRAME2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, TIMEFRAME2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
//         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
//         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram < MACDSignal && MACDHistogram > 0)
//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram < 0)
//         if(Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3])
         if(Open[0] < Open[1] && Open[1] < Open[2])
//         if(Open[0] < Open[3])
         if(Open[0] < High[1] && High[1] < High[2])
            result = 1;
         
         break;
      }
      case _CLOSE_LONG:
      {
         if(iOpen(_SYMBOL, TIMEFRAME2, 0) < iOpen(_SYMBOL, TIMEFRAME2, 1))
            result = 1;
         if(iClose(_SYMBOL, TIMEFRAME2, 1) < iClose(_SYMBOL, TIMEFRAME2, 2))
            result = 1;
/*
         if(iOpen(_SYMBOL, _TIMEFRAME, 0) < iOpen(_SYMBOL, _TIMEFRAME, 1))
            result = 1;
         if(iClose(_SYMBOL, _TIMEFRAME, 1) < iClose(_SYMBOL, _TIMEFRAME, 2))
            result = 1;
*/         
         break;
      }
      case _CLOSE_SHORT:
      {
         if(iOpen(_SYMBOL, TIMEFRAME2, 0) > iOpen(_SYMBOL, TIMEFRAME2, 1))
            result = 1;
         if(iClose(_SYMBOL, TIMEFRAME2, 1) > iClose(_SYMBOL, TIMEFRAME2, 2))
            result = 1;
/*
         if(iOpen(_SYMBOL, _TIMEFRAME, 0) > iOpen(_SYMBOL, _TIMEFRAME, 1))
            result = 1;
         if(iClose(_SYMBOL, _TIMEFRAME, 1) > iClose(_SYMBOL, _TIMEFRAME, 2))
            result = 1;
*/
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, 1);
         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, 1);
         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         for(int i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  i = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());
                  
                  double Low1SL = iLow(_SYMBOL, _TIMEFRAME, 1);
                  double Low2SL = Bid - MathAbs(OrderOpenPrice() - iLow(_SYMBOL, _TIMEFRAME, i + 1));

                  if(Low1SL < Low2SL)
                     result = Low1SL;
                  else
                     result = Low2SL;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = 0;
               }
               else
               {
                  int j = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());

                  double High1SL = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  double High2SL = Ask + MathAbs(iHigh(_SYMBOL, _TIMEFRAME, j + 1) - OrderOpenPrice());
                  
                  if(High1SL > High2SL)
                     result = High1SL;
                  else
                     result = High2SL;
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                  if(result >= OrderStopLoss())
                     result = 0;
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_006(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 6;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;

   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MALong1;
   double   MACDHistogram;
   double   MACDSignal;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MAFast > MASlow)
         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)
         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MAFast < MASlow)
         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)
         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);

         if(MAFast < MASlow)
            result = 1;
                  
         break;
      }
      case _CLOSE_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);

         if(MAFast > MASlow)
            result = 1;
                  
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;

//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_LOWER, 1);
         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         break;

//         result = iFractals(_SYMBOL, _TIMEFRAME, MODE_UPPER, 1);
         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;

         for(int i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  i = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());
                  
                  double Low1SL = iLow(_SYMBOL, _TIMEFRAME, 1);
                  double Low2SL = Bid - MathAbs(OrderOpenPrice() - iLow(_SYMBOL, _TIMEFRAME, i + 1));

                  if(Low1SL < Low2SL)
                     result = Low1SL;
                  else
                     result = Low2SL;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = 0;
               }
               else
               {
                  int j = iBarShift(_SYMBOL, _TIMEFRAME, OrderOpenTime());

                  double High1SL = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  double High2SL = Ask + MathAbs(iHigh(_SYMBOL, _TIMEFRAME, j + 1) - OrderOpenPrice());
                  
                  if(High1SL > High2SL)
                     result = High1SL;
                  else
                     result = High2SL;
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                  if(result >= OrderStopLoss())
                     result = 0;
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_007(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 7;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;

   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
         if(Ask > MALong)
//         if(MAFast > MALong)
         if(MALong1 < MALong)
         if(MACDHistogram1 <= MACDSignal1 && MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
         if(Bid < MALong)
//         if(MAFast < MALong)
         if(MALong1 > MALong)
         if(MACDHistogram1 >= MACDSignal1 && MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);


//         if(MAFast < MASlow)
//            result = 1;
                  
         break;
      }
      case _CLOSE_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);


//         if(MAFast > MASlow)
//            result = 1;
                  
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

           result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = 0;
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_008(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 8;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;

   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MACDHistogram1 <= MACDSignal1 && MACDHistogram > MACDSignal)

//         if(MAFast > MASlow)
         if(Ask > MALong)
//         if(MAFast > MALong)
         if(MALong1 < MALong)
         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MACDHistogram1 >= MACDSignal1 && MACDHistogram < MACDSignal)

//         if(MAFast < MASlow)
         if(Bid < MALong)
//         if(MAFast < MALong)
         if(MALong1 > MALong)
         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {         
         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) > iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }

         break;
      }
      case _CLOSE_SHORT:
      {
         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
//                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) < iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

           result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_009(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 9;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = PERIOD_M30;
   int      _TIMEFRAME_2   = PERIOD_H1;
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   
   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MACDHistogram2;
   double   MACDSignal2;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//         if(MACDHistogram1 >= MACDSignal1)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
//            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
//                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_010(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 10;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = Period();
   int      _TIMEFRAME_2   = HigherTimeframe(_TIMEFRAME);
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   
   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MACDHistogram2;
   double   MACDSignal2;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

         if(Ask > MALong)
//         if(MAFast > MALong)
         if(MALong1 < MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

         if(MACDHistogram1 >= MACDSignal1)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)

         if(Bid < MALong)
//         if(MAFast < MALong)
         if(MALong1 > MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

         if(MACDHistogram1 >= MACDSignal1)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)

         if(Bid < MALong)
//         if(MAFast < MALong)
         if(MALong1 > MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

         if(Ask > MALong)
//         if(MAFast > MALong)
         if(MALong1 < MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         double breakeven = 0;
         
/*
         for(int i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven > Bid - 10*Point)
                     breakeven = Bid - 10*Point;
                  
                  if(breakeven <= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
               else
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) < OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven < Ask + 10*Point)
                     breakeven = Ask + 10*Point;
                     
                  if(breakeven >= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
            }
         }
*/
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
//            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;

                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_011(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 11;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
//   int      _TIMEFRAME     = _TIMEFRAME;
   int      _TIMEFRAME_2   = HigherTimeframe(_TIMEFRAME);
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   
   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;
   double   MAFast2;
   double   MASlow2;
   double   MALong2;
   double   MACDHistogram2;
   double   MACDSignal2;
   double   T2_MACDHistogram;
   double   T2_MACDSignal;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         _PRICE = PRICE_LOW;
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

         if(MACDHistogram1 > MACDHistogram2)
         if(MACDSignal1 < MACDSignal2)
         if(MACDHistogram1 <= MACDSignal1)
         if(MACDHistogram1 < 0)
         if(MACDSignal1 < 0)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)
//         if(MAFast1 > MASlow1)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)
         if(MALong2 < MALong1)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
//         _PRICE = PRICE_HIGH;
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);


//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

         if(MACDHistogram1 < MACDHistogram2)
         if(MACDSignal1 > MACDSignal2)
         if(MACDHistogram1 >= MACDSignal1)
         if(MACDHistogram1 > 0)
         if(MACDSignal1 > 0)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)
//         if(MAFast1 < MASlow1)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)
         if(MALong2 > MALong1)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         break;
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//         if(MACDHistogram1 >= MACDSignal1)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         double breakeven = 0;
         
/*
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven > Bid - 10*Point)
                     breakeven = Bid - 10*Point;
                  
                  if(breakeven <= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
               else
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) < OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven < Ask + 10*Point)
                     breakeven = Ask + 10*Point;
                     
                  if(breakeven >= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
            }
         }
*/
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
//            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;

                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;
               
            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_012(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 12;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
//   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
   int      _TIMEFRAME     = _TIMEFRAME;
   int      _TIMEFRAME_2   = HigherTimeframe(_TIMEFRAME);
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   
   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;
   double   MAFast2;
   double   MASlow2;
   double   MALong2;
   double   MACDHistogram2;
   double   MACDSignal2;
   double   T2_MACDHistogram;
   double   T2_MACDSignal;
   double   UpperFractalHL;
   double   LowerFractalHL;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         _PRICE = PRICE_LOW;
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         UpperFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         LowerFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);

//         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 > MACDHistogram2)
//         if(MACDSignal1 < MACDSignal2)
//         if(MACDHistogram1 <= MACDSignal1)
//         if(MACDHistogram1 < 0)
//         if(MACDSignal1 < 0)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)
//         if(MAFast1 > MASlow1)

         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)
//         if(MALong2 < MALong1)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))

         if(Ask > UpperFractalHL - 10*Point && Low[0] < UpperFractalHL)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
//         _PRICE = PRICE_HIGH;
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         UpperFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         LowerFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);

//         if(MACDHistogram > MACDSignal)
         if(MACDHistogram < MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//       if(MACDHistogram1 < MACDHistogram2)
//       if(MACDSignal1 > MACDSignal2)
//       if(MACDHistogram1 >= MACDSignal1)
//       if(MACDHistogram1 > 0)
//       if(MACDSignal1 > 0)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)
//         if(MAFast1 < MASlow1)

         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)
//        if(MALong2 > MALong1)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))

         if(Bid < LowerFractalHL + 10*Point && High[0] > LowerFractalHL)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         break;
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//         if(MACDHistogram1 >= MACDSignal1)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         double breakeven = 0;
         
/*
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven > Bid - 10*Point)
                     breakeven = Bid - 10*Point;
                  
                  if(breakeven <= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
               else
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) < OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven < Ask + 10*Point)
                     breakeven = Ask + 10*Point;
                     
                  if(breakeven >= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
            }
         }
*/
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;
                  
                  if(result > Bid - 15*Point)
                     result = Bid - 15*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;

                  if(result < Ask + 15*Point)
                     result = Ask + 15*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_013(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 13;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
//   int      _TIMEFRAME     = _TIMEFRAME;
   int      _TIMEFRAME_2   = HigherTimeframe(_TIMEFRAME);
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   double   result         = 0;
   
   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;
   double   MAFast2;
   double   MASlow2;
   double   MALong2;
   double   MACDHistogram2;
   double   MACDSignal2;
   double   T2_MACDHistogram;
   double   T2_MACDSignal;
   double   UpperFractalHL;
   double   LowerFractalHL;

   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         _PRICE = PRICE_LOW;
         if(!OpenNewBar(_TIMEFRAME))
            return(0);
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         UpperFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         LowerFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);

//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0)
         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 > MACDHistogram2)
//         if(MACDSignal1 < MACDSignal2)
//         if(MACDHistogram1 <= MACDSignal1)
//         if(MACDHistogram1 < 0)
//         if(MACDSignal1 < 0)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)
//         if(MAFast1 > MASlow1)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)
//         if(MALong2 < MALong1)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))

//         if(Ask > UpperFractalHL - 10*Point && Low[0] < UpperFractalHL)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
//         _PRICE = PRICE_HIGH;
         if(!OpenNewBar(_TIMEFRAME))
            return(0);
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         UpperFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         LowerFractalHL = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);

//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0)
         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//       if(MACDHistogram1 < MACDHistogram2)
//       if(MACDSignal1 > MACDSignal2)
//       if(MACDHistogram1 >= MACDSignal1)
//       if(MACDHistogram1 > 0)
//       if(MACDSignal1 > 0)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)
//         if(MAFast1 < MASlow1)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)
//        if(MALong2 > MALong1)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))

//         if(Bid < LowerFractalHL + 10*Point && High[0] > LowerFractalHL)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
//         break;
         if(!OpenNewBar(_TIMEFRAME))
            return(0);
         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0)
         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//         if(MACDHistogram1 >= MACDSignal1)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
//         break;
         if(!OpenNewBar(_TIMEFRAME))
            return(0);

         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0)
         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;

         double breakeven = 0;
         
/*
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven > Bid - 10*Point)
                     breakeven = Bid - 10*Point;
                  
                  if(breakeven <= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
               else
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) < OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven < Ask + 10*Point)
                     breakeven = Ask + 10*Point;
                     
                  if(breakeven >= OrderStopLoss())
                     breakeven = OrderStopLoss();
               }
            }
         }
*/
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false) - 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;
                  
                  if(result > Bid - 15*Point)
                     result = Bid - 15*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true) + 5*Point;
                  
                  if(breakeven > result)
                     result = breakeven;

                  if(result < Ask + 15*Point)
                     result = Ask + 15*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_014(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 14;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
   int      _TIMEFRAME_2   = _TIMEFRAME;
//   int      _TIMEFRAME_2   = HigherTimeframe(_TIMEFRAME);
//   int      _TIMEFRAME_2   = HigherTimeframe(HigherTimeframe(_TIMEFRAME));
//   int      _TIMEFRAME_2   = HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME)));
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _MAMETHOD      = MODE_EMA;
   int      _SLOWMA        = 20;
   int      _FASTMA        = 10;
   int      _LONGMA        = LONGMA;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;
   int      _MAXSTOPLOSS   = 0;
   int      _MAX_FRACTAL_DISTANCE = 1000;
      
   double   result         = 0;
   
   double   MAFast;
   double   MASlow;
   double   MALong;
   double   MACDHistogram;
   double   MACDSignal;
   double   MAFast1;
   double   MASlow1;
   double   MALong1;
   double   MACDHistogram1;
   double   MACDSignal1;
   double   MAFast2;
   double   MASlow2;
   double   MALong2;
   double   MACDHistogram2;
   double   MACDSignal2;
   double   T2_MACDHistogram;
   double   T2_MACDSignal;

   double   UpperFractal1;
   double   LowerFractal1;
   datetime UpperFractalTime1;
   datetime LowerFractalTime1;
   int      UpperFractalShift1;
   int      LowerFractalShift1;
   double   UpperFractal2;
   double   LowerFractal2;
   datetime UpperFractalTime2;
   datetime LowerFractalTime2;
   int      UpperFractalShift2;
   int      LowerFractalShift2;
   double   EdgePrice;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         if(!OpenNewBar(_TIMEFRAME))
//            break;

/*         
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);
*/
/*
         UpperFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
         UpperFractalTime1 = getLastFractalTime(_SYMBOL, _TIMEFRAME, true);
         UpperFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true);
         UpperFractalTime2 = getPreviousFractalTime(_SYMBOL, _TIMEFRAME, true);
*/

         UpperFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         UpperFractalTime1 = getLastFractalTime(_SYMBOL, _TIMEFRAME_2, true);
         UpperFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         UpperFractalTime2 = getPreviousFractalTime(_SYMBOL, _TIMEFRAME_2, true);
         LowerFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, false);
         LowerFractalTime1 = getLastFractalTime(_SYMBOL, _TIMEFRAME_2, false);
         LowerFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME_2, false);
         LowerFractalTime2 = getPreviousFractalTime(_SYMBOL, _TIMEFRAME_2, false);

         UpperFractalShift1 = iBarShift(_SYMBOL, _TIMEFRAME, UpperFractalTime1);
         UpperFractalShift2 = iBarShift(_SYMBOL, _TIMEFRAME, UpperFractalTime2);
         LowerFractalShift1 = iBarShift(_SYMBOL, _TIMEFRAME, LowerFractalTime1);
         LowerFractalShift2 = iBarShift(_SYMBOL, _TIMEFRAME, LowerFractalTime2);
         
         EdgePrice = UpperFractal2 - (UpperFractal2 - UpperFractal1) * (UpperFractalShift2 / (UpperFractalShift2 - UpperFractalShift1));

//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < 0)
//         if(MACDHistogram > 0)
//         if(MACDSignal < 0)

//         if(MACDHistogram1 <= MACDSignal1)

//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 > 0)
//         if(MACDHistogram2 < 0)
//         if(MACDSignal2 < 0)
//         if(MACDSignal2 > 0)

//         if(MAFast1 < MASlow1 && MAFast > MASlow)
//         if(MAFast > MASlow)

//         if(Ask > MALong)
//         if(MAFast > MALong)
//         if(MALong1 < MALong)

//         Print(Ask, " - ", UpperFractal2 - (UpperFractal2 - UpperFractal1) * (UpperFractalShift2 / (UpperFractalShift2 - UpperFractalShift1)));
         if(Ask > EdgePrice)
         if(Ask < LowerFractal1 + _MAX_FRACTAL_DISTANCE*Point)
         if(UpperFractal2 >= UpperFractal1)
            result = 1;
                  
         break;
      }
      case _OPEN_SHORT:
      {
//         if(!OpenNewBar(_TIMEFRAME))
//            break;
/*
         MAFast = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MASlow = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MALong = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT);
         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         MAFast1 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MASlow1 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MALong1 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 1);
         MACDHistogram1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 1);
         MACDSignal1 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 1);

         MAFast2 = iMA(_SYMBOL, _TIMEFRAME, _FASTMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MASlow2 = iMA(_SYMBOL, _TIMEFRAME, _SLOWMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MALong2 = iMA(_SYMBOL, _TIMEFRAME, _LONGMA, 0, _MAMETHOD, _PRICE, _SHIFT + 2);
         MACDHistogram2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT + 2);
         MACDSignal2 = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT + 2);

         T2_MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         T2_MACDSignal = iMACD(_SYMBOL, _TIMEFRAME_2, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);
*/
/*         
         LowerFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
         LowerFractalTime1 = getLastFractalTime(_SYMBOL, _TIMEFRAME, false);
         LowerFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false);
         LowerFractalTime2 = getPreviousFractalTime(_SYMBOL, _TIMEFRAME, false);
*/
         UpperFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         UpperFractalTime1 = getLastFractalTime(_SYMBOL, _TIMEFRAME_2, true);
         UpperFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME_2, true);
         UpperFractalTime2 = getPreviousFractalTime(_SYMBOL, _TIMEFRAME_2, true);
         LowerFractal1 = getLastFractalValue(_SYMBOL, _TIMEFRAME_2, false);
         LowerFractalTime1 = getLastFractalTime(_SYMBOL, _TIMEFRAME_2, false);
         LowerFractal2 = getPreviousFractalValue(_SYMBOL, _TIMEFRAME_2, false);
         LowerFractalTime2 = getPreviousFractalTime(_SYMBOL, _TIMEFRAME_2, false);

         UpperFractalShift1 = iBarShift(_SYMBOL, _TIMEFRAME, UpperFractalTime1);
         UpperFractalShift2 = iBarShift(_SYMBOL, _TIMEFRAME, UpperFractalTime2);
         LowerFractalShift1 = iBarShift(_SYMBOL, _TIMEFRAME, LowerFractalTime1);
         LowerFractalShift2 = iBarShift(_SYMBOL, _TIMEFRAME, LowerFractalTime2);

         EdgePrice = LowerFractal2 - (LowerFractal2 - LowerFractal1) * (LowerFractalShift2 / (LowerFractalShift2 - LowerFractalShift1));
         
//         if(MACDHistogram > MACDSignal)
//         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
//         if(MACDSignal > 0)

//       if(MACDHistogram1 < MACDHistogram2)
//       if(MACDSignal1 > MACDSignal2)
//       if(MACDHistogram1 >= MACDSignal1)
//       if(MACDHistogram1 > 0)
//       if(MACDSignal1 > 0)

//         if(MACDHistogram2 > MACDSignal2)
//         if(MACDHistogram2 < MACDSignal2)
//         if(MACDHistogram2 < 0)
//         if(MACDHistogram2 > 0)
//         if(MACDSignal2 > 0)
//         if(MACDSignal2 < 0)

//         if(MAFast1 > MASlow1 && MAFast < MASlow)
//         if(MAFast < MASlow)
//         if(MAFast1 < MASlow1)

//         if(Bid < MALong)
//         if(MAFast < MALong)
//         if(MALong1 > MALong)
//        if(MALong2 > MALong1)

//         Print(Bid, " - ", LowerFractal2 - (LowerFractal2 - LowerFractal1) * (LowerFractalShift2 / (LowerFractalShift2 - LowerFractalShift1)));
         if(Bid < EdgePrice)
         if(Bid > UpperFractal1 - _MAX_FRACTAL_DISTANCE*Point)
         if(LowerFractal2 <= LowerFractal1)
            result = 1;
                  
         break;
      }
      case _CLOSE_LONG:
      {
         if(!OpenNewBar(_TIMEFRAME))
            break;

         break;

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                      result = 1;
               }
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
         if(!OpenNewBar(_TIMEFRAME))
            break;

         break;

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         if(_MAXSTOPLOSS > 0)
            if(result < Ask - _MAXSTOPLOSS*Point)
               result = Ask - _MAXSTOPLOSS*Point;
            
         if(result > Ask - 10*Point)
            result = Ask - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);

         if(_MAXSTOPLOSS > 0)
            if(result > Bid + _MAXSTOPLOSS*Point)
               result = Bid + _MAXSTOPLOSS*Point;

         if(result < Bid + 10*Point)
            result = Bid + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         if(!OpenNewBar(_TIMEFRAME))
            break;

//         break;

         double breakeven = 0;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven > Bid - 10*Point)
                     breakeven = Bid - 10*Point;
               }
               else
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) < OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven < Ask + 10*Point)
                     breakeven = Ask + 10*Point;
               }
            }
         }

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

//            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(breakeven > result)
                     result = breakeven;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(breakeven < result)
                     result = breakeven;

                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = Bid + MathAbs(Bid - OrderStopLoss());
               }
               else
               {
                  result = Ask - MathAbs(Ask - OrderStopLoss());
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(result > Bid)
                     result = Bid;
                  
                  if(result <= Bid)
                     result = 0;
               }
               else
               {
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(result < Ask)
                     result = Ask;
                     
                  if(result >= Ask)
                     result = 0;
               }
            }
         }
         
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_015(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 15;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
      
   int      _DIFF          = 0;
   
   double   result         = 0;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         break;
      }
      case _OPEN_SHORT:
      {
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         if(!OpenNewBar(_TIMEFRAME))
            break;

         if(High[1] < High[2])
         if(Low[1] > Low[2])
//         if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
         if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//         if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
            result = 1;
                  
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         if(!OpenNewBar(_TIMEFRAME))
            break;

         if(High[1] < High[2])
         if(Low[1] > Low[2])
//         if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
         if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//         if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
            result = 1;
                  
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
//         break;

         result = High[1] + _DIFF*Point;

         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
//         break;

         result = Low[1] - _DIFF*Point;
         
         break;
      }
      case _CLOSE_LONG:
      {
//         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         result = 1;

         break;
      }
      case _CLOSE_SHORT:
      {
//         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         result = 1;
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = Low[2];

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = High[2];
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         result = High[2];

         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         result = Low[2];

         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         result = iTime(_SYMBOL, _TIMEFRAME, 0) + _TIMEFRAME*60;
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_016(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 16;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
   int      _SLOWEMA       = 26;
   int      _FASTEMA       = 12;
   int      _MASIGNAL      = 9;
   int      _SHIFT         = 0;
   int      _PRICE         = PRICE_OPEN;

   int      _DIFF          = 0;
   
   double   result         = 0;
   double   MACDHistogram;
   double   MACDSignal;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         switch(_SIGNAL_COMBINATION)
         {
            case 1:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 2:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 3:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 4:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 5:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 6:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 7:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 8:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 9:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 10:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 11:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 12:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 13:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 14:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 15:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 16:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 17:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 18:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 19:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 20:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 21:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 22:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 23:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 24:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 25:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 26:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
            case 27:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Ask > High[1] + _DIFF*Point)
                  result = 1;
               break;
            }
         }
              
         break;
      }
      case _OPEN_SHORT:
      {
//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         MACDHistogram = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_MAIN, _SHIFT);
         MACDSignal = iMACD(_SYMBOL, _TIMEFRAME, _FASTEMA, _SLOWEMA, _MASIGNAL, _PRICE, MODE_SIGNAL, _SHIFT);

         switch(_SIGNAL_COMBINATION)
         {
            case 1:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 2:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 3:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 4:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 5:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 6:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 7:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 8:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 9:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 10:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 11:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 12:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 13:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 14:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 15:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 16:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 17:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 18:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 19:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 20:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 21:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 22:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 23:
            {
//               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 24:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 25:
            {
//               if(MACDHistogram > MACDSignal)
               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 26:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
//               if(MACDHistogram < 0)
               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
            case 27:
            {
               if(MACDHistogram > MACDSignal)
//               if(MACDHistogram < MACDSignal)
               if(MACDHistogram < 0)
//               if(MACDHistogram > 0)
               if(High[1] < High[2])
               if(Low[1] > Low[2])
//               if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//               if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
               if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
               if(Bid < Low[1] - _DIFF*Point)
                  result = 1;
               break;
            }
         }

/*
         if(MACDHistogram < MACDSignal)
//         if(MACDHistogram > MACDSignal)
         if(MACDHistogram > 0)
//         if(MACDHistogram < 0)
         if(High[1] < High[2])
         if(Low[1] > Low[2])
         if(MathAbs(Open[1] - Close[1]) < MathAbs(Open[2] - Close[2]))
//         if((Open[2] > Close[2] && Open[2] > Open[1] && Open[2] > Close[1] && Close[2] < Open[1] && Close[2] < Close[1]) || (Open[2] < Close[2] && Open[2] < Open[1] && Open[2] < Close[1] && Close[2] > Open[1] && Close[2] > Close[1]))
//         if((Open[2] > Close[2] && Open[2] > High[1] && Close[2] < Low[1]) || (Open[2] < Close[2] && Open[2] < Low[1] && Close[2] > High[1]))
         if(Bid < Low[1] - _DIFF*Point)
            result = 1;
*/
                  
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _CLOSE_LONG:
      {
//         break;

         if(Bid > High[2])
            result = 1;

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(High[2] > High[1])
                  result = 1;
            }
         }

         break;
      }
      case _CLOSE_SHORT:
      {
//         break;

         if(Ask < Low[2])
            result = 1;

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(Low[2] < Low[1])
                  result = 1;
            }
         }

         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         break;

         result = Low[2];
//         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
         if(result > Bid - 10*Point)
            result = Bid - 10*Point;

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         break;

         result = High[2];
//         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
         if(result < Ask + 10*Point)
            result = Ask + 10*Point;
         
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         double breakeven = 0;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven > Bid - 10*Point)
                     breakeven = Bid - 10*Point;
               }
               else
               {
                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) < OrderOpenPrice())
                     breakeven = OrderOpenPrice();
                  
                  if(breakeven < Ask + 10*Point)
                     breakeven = Ask + 10*Point;
               }
            }
         }

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
                  
                  if(breakeven > result)
                     result = breakeven;
                  
                  if(result > Bid - 10*Point)
                     result = Bid - 10*Point;
                  
                  if(result <= OrderStopLoss())
                     result = OrderStopLoss();
               }
               else
               {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
                  result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
                  
                  if(breakeven < result)
                     result = breakeven;

                  if(result < Ask + 10*Point)
                     result = Ask + 10*Point;
                     
                  if(result >= OrderStopLoss())
                     result = OrderStopLoss();
               }
            }
         }
         
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;

//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;

         result = iTime(_SYMBOL, _TIMEFRAME, 0) + _TIMEFRAME*60;

         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_017(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 17;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   result         = 0;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;
         if(iVolume(Symbol(), PERIOD_W1, 0) == 1)

// if there was a weekly gap
         if(iClose(Symbol(), PERIOD_W1, 1) > iOpen(Symbol(), PERIOD_W1, 0))
// if there is still a gap
         if(iClose(Symbol(), PERIOD_W1, 1) > iHigh(Symbol(), PERIOD_W1, 0))
// if price is inside of this gap
         if(Ask < iClose(Symbol(), PERIOD_W1, 1) && Ask >= iOpen(Symbol(), PERIOD_W1, 0))
            result = 1;

         break;
      }
      case _OPEN_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;
         if(iVolume(Symbol(), PERIOD_W1, 0) == 1)
            
// if there was a weekly gap
         if(iClose(Symbol(), PERIOD_W1, 1) < iOpen(Symbol(), PERIOD_W1, 0))
// if there is still a gap
         if(iClose(Symbol(), PERIOD_W1, 1) < iLow(Symbol(), PERIOD_W1, 0))
// if price is inside of this gap
         if(Bid > iClose(Symbol(), PERIOD_W1, 1) && Bid <= iOpen(Symbol(), PERIOD_W1, 0))
            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
//         if(Ask >= iClose(Symbol(), PERIOD_D1, 1))
         if(Ask >= iClose(Symbol(), PERIOD_W1, 1))
            result = 1;
            
            break;
      }
      case _CLOSE_SHORT:
      {
//         if(Bid <= iClose(Symbol(), PERIOD_D1, 1))
         if(Bid <= iClose(Symbol(), PERIOD_W1, 1))
            result = 1;
            
            break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         result = Ask - 50*Point;
         
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         result = Bid + 50*Point;
         
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;
         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_018(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 18;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   result         = 0;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

            result = 1;

         break;
      }
      case _OPEN_SHORT:
      {
         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         break;

            result = 1;
            
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

            result = 1;
            
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_019(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 19;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   result         = 0;
   
   int      i;

   double   ZZLastTop;
   double   ZZLastBottom;
   double   BBTop;
   double   BBBottom;
   
   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         ZZLastTop = iCustom(Symbol(), _TIMEFRAME, "ZigZag", 1, 0);
         ZZLastBottom = iCustom(Symbol(), _TIMEFRAME, "ZigZag", 2, 0);
         BBTop = iBands(Symbol(), _TIMEFRAME, 20, 2, 0, PRICE_CLOSE, 1, 0);
         BBBottom = iBands(Symbol(), _TIMEFRAME, 20, 2, 0, PRICE_CLOSE, 2, 0);
         
         if(Ask > BBBottom)
         if(ZZLastTop > BBBottom)
            result = 1;

         break;
      }
      case _OPEN_SHORT:
      {
         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         ZZLastTop = iCustom(Symbol(), _TIMEFRAME, "ZigZag", 1, 0);
         ZZLastBottom = iCustom(Symbol(), _TIMEFRAME, "ZigZag", 2, 0);
         BBTop = iBands(Symbol(), _TIMEFRAME, 20, 2, 0, PRICE_CLOSE, 1, 0);
         BBBottom = iBands(Symbol(), _TIMEFRAME, 20, 2, 0, PRICE_CLOSE, 2, 0);

            result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         break;

            result = 1;
            
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

            result = 1;
            
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_020(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 20;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   result         = 0;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         Print(1, iCustom(Symbol(), _TIMEFRAME, "ZigZag", 1, 1));
         Print(2, iCustom(Symbol(), HigherTimeframe(_TIMEFRAME), "ZigZag", 1, 1));
         Print(3, iCustom(Symbol(), HigherTimeframe(HigherTimeframe(_TIMEFRAME)), "ZigZag", 1, 1));
         Print(4, iCustom(Symbol(), HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME))), "ZigZag", 1, 1));

         if(Ask > iCustom(Symbol(), _TIMEFRAME, "ZigZag", 1, 0))
         if(Ask > iCustom(Symbol(), HigherTimeframe(_TIMEFRAME), "ZigZag", 1, 0))
         if(Ask > iCustom(Symbol(), HigherTimeframe(HigherTimeframe(_TIMEFRAME)), "ZigZag", 1, 0))
         if(Ask > iCustom(Symbol(), HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME))), "ZigZag", 1, 0))
            result = 1;

         break;
      }
      case _OPEN_SHORT:
      {
//         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         Print(5, iCustom(Symbol(), _TIMEFRAME, "ZigZag", 2, 1));
         Print(6, iCustom(Symbol(), HigherTimeframe(_TIMEFRAME), "ZigZag", 2, 1));
         Print(7, iCustom(Symbol(), HigherTimeframe(HigherTimeframe(_TIMEFRAME)), "ZigZag", 2, 1));
         Print(8, iCustom(Symbol(), HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME))), "ZigZag", 2, 1));

         if(Bid < iCustom(Symbol(), _TIMEFRAME, "ZigZag", 2, 0))
         if(Bid < iCustom(Symbol(), HigherTimeframe(_TIMEFRAME), "ZigZag", 2, 0))
         if(Bid < iCustom(Symbol(), HigherTimeframe(HigherTimeframe(_TIMEFRAME)), "ZigZag", 2, 0))
         if(Bid < iCustom(Symbol(), HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME))), "ZigZag", 2, 0))
             result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
//         break;

         if(Bid < iCustom(Symbol(), _TIMEFRAME, "ZigZag", 2, 0))
//         if(Bid < iCustom(Symbol(), HigherTimeframe(_TIMEFRAME), "ZigZag", 2, 0))
//         if(Bid < iCustom(Symbol(), HigherTimeframe(HigherTimeframe(_TIMEFRAME)), "ZigZag", 2, 0))
//         if(Bid < iCustom(Symbol(), HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME))), "ZigZag", 2, 0))
             result = 1;
            
         break;
      }
      case _CLOSE_SHORT:
      {
//         break;

         if(Ask > iCustom(Symbol(), _TIMEFRAME, "ZigZag", 1, 0))
//         if(Ask > iCustom(Symbol(), HigherTimeframe(_TIMEFRAME), "ZigZag", 1, 0))
//         if(Ask > iCustom(Symbol(), HigherTimeframe(HigherTimeframe(_TIMEFRAME)), "ZigZag", 1, 0))
//         if(Ask > iCustom(Symbol(), HigherTimeframe(HigherTimeframe(HigherTimeframe(_TIMEFRAME))), "ZigZag", 1, 0))
            result = 1;
            
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_021(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 21;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   UpperZIGZAG1;
   double   LowerZIGZAG1;
   datetime UpperZIGZAGTime1;
   datetime LowerZIGZAGTime1;
   int      UpperZIGZAGShift1;
   int      LowerZIGZAGShift1;
   double   UpperZIGZAG2;
   double   LowerZIGZAG2;
   datetime UpperZIGZAGTime2;
   datetime LowerZIGZAGTime2;
   int      UpperZIGZAGShift2;
   int      LowerZIGZAGShift2;
   double   LastUpperFractal;
   double   LastLowerFractal;

   int      BreakOutTreshold = 0;
   double   EdgePrice;
   static datetime LastZIGZAGTime = 0;

   double   result         = 0;
   
   int      i;

//   Print(_TIMEFRAME);

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAGTime2 = getPreviousZIGZAGTime(_SYMBOL, _TIMEFRAME, true);

         LowerZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, false);

         UpperZIGZAGShift1 = iBarShift(_SYMBOL, _TIMEFRAME, UpperZIGZAGTime1);
         UpperZIGZAGShift2 = iBarShift(_SYMBOL, _TIMEFRAME, UpperZIGZAGTime2);
         
//         LastUpperFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         LastLowerFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);

//         EdgePrice = UpperZIGZAG2 - (UpperZIGZAG2 - UpperZIGZAG1) * (UpperZIGZAGShift2 / (UpperZIGZAGShift2 - UpperZIGZAGShift1));
         EdgePrice = UpperZIGZAG1 + UpperZIGZAGShift1 * (UpperZIGZAG1 - UpperZIGZAG2) / (UpperZIGZAGShift2 - UpperZIGZAGShift1);

//         Print(UpperZIGZAG1, " ", UpperZIGZAGTime1, " ", UpperZIGZAG2, " ", UpperZIGZAGTime2, " ", LowerZIGZAG1, " ", LowerZIGZAGTime1, " ", LowerZIGZAG2, " ", LowerZIGZAGTime2, " ", UpperZIGZAGShift1, " ", UpperZIGZAGShift2, " ", LowerZIGZAGShift1, " ", LowerZIGZAGShift2, " ", EdgePrice);

         if(LowerZIGZAGTime1 > UpperZIGZAGTime1)
         if(LastZIGZAGTime != UpperZIGZAGTime1)
//         if(LastUpperFractal > EdgePrice && LastLowerFractal > EdgePrice)
         if(Ask > EdgePrice + BreakOutTreshold*Point)
         {
            result = 1;

//            ObjectCreate(StringConcatenate(UpperZIGZAGTime1, 0), OBJ_TREND, 0, UpperZIGZAGTime1, UpperZIGZAG1, UpperZIGZAGTime2, UpperZIGZAG2);
//            ObjectCreate(StringConcatenate(UpperZIGZAGTime1, 1), OBJ_TREND, 0, UpperZIGZAGTime1, UpperZIGZAG1, Time[0], EdgePrice);
//            ObjectSet(StringConcatenate(UpperZIGZAGTime1, 1), OBJPROP_COLOR, 0x00FFFF);
            
//            Comment(LastZIGZAGTime, " - ", UpperZIGZAGTime1);
            LastZIGZAGTime = UpperZIGZAGTime1;
         }
         
         break;
      }
      case _OPEN_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAGTime2 = getPreviousZIGZAGTime(_SYMBOL, _TIMEFRAME, false);

         UpperZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, true);

         LowerZIGZAGShift1 = iBarShift(_SYMBOL, _TIMEFRAME, LowerZIGZAGTime1);
         LowerZIGZAGShift2 = iBarShift(_SYMBOL, _TIMEFRAME, LowerZIGZAGTime2);
         
//         LastUpperFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         LastLowerFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);

//         EdgePrice = LowerZIGZAG2 - (LowerZIGZAG2 - LowerZIGZAG1) * (LowerZIGZAGShift2 / (LowerZIGZAGShift2 - LowerZIGZAGShift1));
         EdgePrice = LowerZIGZAG1 + LowerZIGZAGShift1 * (LowerZIGZAG1 - LowerZIGZAG2) / (LowerZIGZAGShift2 - LowerZIGZAGShift1);

//         Print(UpperZIGZAG1, " ", UpperZIGZAGTime1, " ", UpperZIGZAG2, " ", UpperZIGZAGTime2, " ", LowerZIGZAG1, " ", LowerZIGZAGTime1, " ", LowerZIGZAG2, " ", LowerZIGZAGTime2, " ", UpperZIGZAGShift1, " ", UpperZIGZAGShift2, " ", LowerZIGZAGShift1, " ", LowerZIGZAGShift2, " ", EdgePrice);
         
         if(LowerZIGZAGTime1 < UpperZIGZAGTime1)
         if(LastZIGZAGTime != LowerZIGZAGTime1)
//         if(LastUpperFractal < EdgePrice && LastLowerFractal < EdgePrice)
         if(Bid < EdgePrice - BreakOutTreshold*Point)
         {
            result = 1;

//            ObjectCreate(StringConcatenate(LowerZIGZAGTime1, 0), OBJ_TREND, 0, LowerZIGZAGTime1, LowerZIGZAG1, LowerZIGZAGTime2, LowerZIGZAG2);
//            ObjectCreate(StringConcatenate(LowerZIGZAGTime1, 1), OBJ_TREND, 0, LowerZIGZAGTime1, LowerZIGZAG1, Time[0], EdgePrice);
//            ObjectSet(StringConcatenate(LowerZIGZAGTime1, 1), OBJPROP_COLOR, 0x00FFFF);
            
//            Comment(LastZIGZAGTime, " - ", LowerZIGZAGTime1);
            LastZIGZAGTime = LowerZIGZAGTime1;
         }
         
         break;
      }
      case _CLOSE_LONG:
      {
         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
//               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_CLOSE, 1) < 100)
               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_OPEN, 0) < 100)
                  result = 1;
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                   result = 1;
            }
         }

         break;

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
//               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_CLOSE, 1) > -100)
               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_OPEN, 0) > -100)
                  result = 1;
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                  result = 1;
            }
         }

         break;
         
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
//         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
         result = iLow(_SYMBOL, _TIMEFRAME, 1);

         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
//         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
         result = iHigh(_SYMBOL, _TIMEFRAME, 1);
         
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
//         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

//            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
               }
               if(OrderType() == OP_SELL)
               {
                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
               }
            }
         }

         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_022(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 22;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   UpperZIGZAG1;
   double   LowerZIGZAG1;
   datetime UpperZIGZAGTime1;
   datetime LowerZIGZAGTime1;
   int      UpperZIGZAGShift1;
   int      LowerZIGZAGShift1;
   double   UpperZIGZAG2;
   double   LowerZIGZAG2;
   datetime UpperZIGZAGTime2;
   datetime LowerZIGZAGTime2;
   int      UpperZIGZAGShift2;
   int      LowerZIGZAGShift2;
   double   LastUpperFractal;
   double   LastLowerFractal;

   int      BreakOutTreshold = 0;
   double   EdgePrice;
   static datetime LastZIGZAGTime = 0;

   double   result         = 0;
   
   int      i;

//   Print(_TIMEFRAME);

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAGTime2 = getPreviousZIGZAGTime(_SYMBOL, _TIMEFRAME, false);

         UpperZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, true);

         LowerZIGZAGShift1 = iBarShift(_SYMBOL, _TIMEFRAME, LowerZIGZAGTime1);
         LowerZIGZAGShift2 = iBarShift(_SYMBOL, _TIMEFRAME, LowerZIGZAGTime2);
         
//         LastUpperFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         LastLowerFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);

//         EdgePrice = LowerZIGZAG2 - (LowerZIGZAG2 - LowerZIGZAG1) * (LowerZIGZAGShift2 / (LowerZIGZAGShift2 - LowerZIGZAGShift1));
         EdgePrice = LowerZIGZAG1 + LowerZIGZAGShift1 * (LowerZIGZAG1 - LowerZIGZAG2) / (LowerZIGZAGShift2 - LowerZIGZAGShift1);

//         Print(UpperZIGZAG1, " ", UpperZIGZAGTime1, " ", UpperZIGZAG2, " ", UpperZIGZAGTime2, " ", LowerZIGZAG1, " ", LowerZIGZAGTime1, " ", LowerZIGZAG2, " ", LowerZIGZAGTime2, " ", UpperZIGZAGShift1, " ", UpperZIGZAGShift2, " ", LowerZIGZAGShift1, " ", LowerZIGZAGShift2, " ", EdgePrice);
         
         if(LowerZIGZAGTime1 < UpperZIGZAGTime1)
         if(LastZIGZAGTime != LowerZIGZAGTime1)
//         if(LastUpperFractal < EdgePrice && LastLowerFractal < EdgePrice)
         if(Ask < EdgePrice)
//         if(Low[1] < EdgePrice)
         {
            result = 1;

//            ObjectCreate(StringConcatenate(LowerZIGZAGTime1, 0), OBJ_TREND, 0, LowerZIGZAGTime1, LowerZIGZAG1, LowerZIGZAGTime2, LowerZIGZAG2);
//            ObjectCreate(StringConcatenate(LowerZIGZAGTime1, 1), OBJ_TREND, 0, LowerZIGZAGTime1, LowerZIGZAG1, Time[0], EdgePrice);
//            ObjectSet(StringConcatenate(LowerZIGZAGTime1, 1), OBJPROP_COLOR, 0x00FFFF);
            
//            Comment(LastZIGZAGTime, " - ", LowerZIGZAGTime1);
            LastZIGZAGTime = LowerZIGZAGTime1;
         }
         
         break;
      }
      case _OPEN_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAGTime2 = getPreviousZIGZAGTime(_SYMBOL, _TIMEFRAME, true);

         LowerZIGZAGTime1 = getLastZIGZAGTime(_SYMBOL, _TIMEFRAME, false);

         UpperZIGZAGShift1 = iBarShift(_SYMBOL, _TIMEFRAME, UpperZIGZAGTime1);
         UpperZIGZAGShift2 = iBarShift(_SYMBOL, _TIMEFRAME, UpperZIGZAGTime2);
         
//         LastUpperFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         LastLowerFractal = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);

//         EdgePrice = UpperZIGZAG2 - (UpperZIGZAG2 - UpperZIGZAG1) * (UpperZIGZAGShift2 / (UpperZIGZAGShift2 - UpperZIGZAGShift1));
         EdgePrice = UpperZIGZAG1 + UpperZIGZAGShift1 * (UpperZIGZAG1 - UpperZIGZAG2) / (UpperZIGZAGShift2 - UpperZIGZAGShift1);

//         Print(UpperZIGZAG1, " ", UpperZIGZAGTime1, " ", UpperZIGZAG2, " ", UpperZIGZAGTime2, " ", LowerZIGZAG1, " ", LowerZIGZAGTime1, " ", LowerZIGZAG2, " ", LowerZIGZAGTime2, " ", UpperZIGZAGShift1, " ", UpperZIGZAGShift2, " ", LowerZIGZAGShift1, " ", LowerZIGZAGShift2, " ", EdgePrice);

         if(LowerZIGZAGTime1 > UpperZIGZAGTime1)
         if(LastZIGZAGTime != UpperZIGZAGTime1)
//         if(LastUpperFractal > EdgePrice && LastLowerFractal > EdgePrice)
//         if(High[1] > EdgePrice)
         if(Bid > EdgePrice)
         {
            result = 1;

//            ObjectCreate(StringConcatenate(UpperZIGZAGTime1, 0), OBJ_TREND, 0, UpperZIGZAGTime1, UpperZIGZAG1, UpperZIGZAGTime2, UpperZIGZAG2);
//            ObjectCreate(StringConcatenate(UpperZIGZAGTime1, 1), OBJ_TREND, 0, UpperZIGZAGTime1, UpperZIGZAG1, Time[0], EdgePrice);
//            ObjectSet(StringConcatenate(UpperZIGZAGTime1, 1), OBJPROP_COLOR, 0x00FFFF);
            
//            Comment(LastZIGZAGTime, " - ", UpperZIGZAGTime1);
            LastZIGZAGTime = UpperZIGZAGTime1;
         }
         
         break;
      }
      case _CLOSE_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

//            if(OrderProfit() > 0)
            {
               if(iCustom(_SYMBOL, _TIMEFRAME, "ZigZag", 12, 5, 3, 0, 0) > 0)
                  result = 1;
            }
         }

         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
//               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_CLOSE, 1) < 100)
               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_OPEN, 0) < 100)
                  result = 1;
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(iHigh(_SYMBOL, _TIMEFRAME, 2) > iHigh(_SYMBOL, _TIMEFRAME, 1))
//                  if(iHigh(_SYMBOL, _TIMEFRAME, 1) > iHigh(_SYMBOL, _TIMEFRAME, 0))
                   result = 1;
            }
         }

         break;

//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Bid < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(Bid > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(Bid < iLow(_SYMBOL, _TIMEFRAME, 1))
                      result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _CLOSE_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

//            if(OrderProfit() > 0)
            {
               if(iCustom(_SYMBOL, _TIMEFRAME, "ZigZag", 12, 5, 3, 0, 0) > 0)
                  result = 1;
            }
         }

         break;

         if(!OpenNewBar(_TIMEFRAME))
            break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
//               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_CLOSE, 1) > -100)
               if(iCCI(_SYMBOL, _TIMEFRAME, 14, PRICE_OPEN, 0) > -100)
                  result = 1;
            }
         }

         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(iLow(_SYMBOL, _TIMEFRAME, 2) < iLow(_SYMBOL, _TIMEFRAME, 1))
//                  if(iLow(_SYMBOL, _TIMEFRAME, 1) > iLow(_SYMBOL, _TIMEFRAME, 0))
                  result = 1;
            }
         }

         break;
         
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(getLastFractalValue(_SYMBOL, _TIMEFRAME, false) < getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false))
//         if(MathAbs(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) - getLastFractalValue(_SYMBOL, _TIMEFRAME, false)) < MathAbs(getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true) - getPreviousFractalValue(_SYMBOL, _TIMEFRAME, false)))
//         if(Ask > getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, true))
//         if(Ask < getLastFractalValue(_SYMBOL, _TIMEFRAME, false))
            result = 1;

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(Ask > iHigh(_SYMBOL, _TIMEFRAME, 1))
                     result = 1;
               }
            }
         }

         break;
         
         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_SELL)
               {
                  if(getLastFractalValue(_SYMBOL, _TIMEFRAME, true) > getPreviousFractalValue(_SYMBOL, _TIMEFRAME, true))
                     result = 1;
               }
            }
         }
         
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
//         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);
         result = Ask - 20*Point;
         
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
//         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);
         result = Bid + 20*Point;
         
         break;
      }
      case _OPEN_PENDING_BUY_STOP:
      {
         break;
      }
      case _OPEN_PENDING_SELL_STOP:
      {
         break;
      }
      case _GET_PENDING_BUY_STOP_PRICE:
      {
         break;
      }
      case _GET_PENDING_SELL_STOP_PRICE:
      {
         break;
      }
      case _GET_LONG_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_SHORT_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_TRAILED_STOPLOSS_PRICE:
      {
         break;

         for(i = 0; i < OrdersTotal(); i++)
         {
            OrderSelect(i, SELECT_BY_POS);
            if(OrderMagicNumber() != _MAGICNUMBER)
               continue;

//            if(OrderProfit() > 0)
            {
               if(OrderType() == OP_BUY)
               {
                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
               }
               if(OrderType() == OP_SELL)
               {
                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
               }
            }
         }

         break;
      }      
      case _GET_TRAILED_TAKEPROFIT_PRICE:
      {
         break;
      }
      case _GET_LOTS:
      {
         result = 0.1;
//         result = GetLots(_MM_FIX_PERC_AVG_LAST_PROFIT, 0.2);
         break;
      }
      case _GET_TRADED_TIMEFRAME:
      {
         result = _TIMEFRAME;

         break;
      }
      case _GET_PENDING_ORDER_EXPIRATION:
      {
         break;
      }
      case _GET_STRATEGY_NUMBER:
      {
         result = _STRATEGY_NUMBER;
         break;
      }
      case _GET_STRATEGY_MAGICNUMBER:
      {
         result = _MAGICNUMBER;
         break;
      }
   }
      
   return(result);
}