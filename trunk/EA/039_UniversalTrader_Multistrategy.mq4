#property copyright "slacktrader"
#property link      "slacktrader"

//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
// main variables                                                         
//------------------------------------------------------------------
//------------------------------------------------------------------
//------------------------------------------------------------------
int   _ALL_STRATEGIES                  = 24;
int   _ACTIVE_STRATEGIES[]             = {23,24};

int   _MIN_STOPLOSS_DISTANCE           = 10;
int   _MIN_TAKEPROFIT_DISTANCE         = 10;

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
extern string  poznamka1 = "0 - vyber timeframe podla dropdown menu - premenna _STRATEGY_TIMEFRAME sa ignoruje";
extern string  poznamka2 = "1 - vyber timeframe podla kodu timeframe 1 - 9";
extern int     _STRATEGY_TIMEFRAME_CHOICE    = 0;
extern int     _STRATEGY_TIMEFRAME           = 1;

extern int     _OPEN_SIGNAL_COMBINATION      = 1;
extern int     _CLOSE_SIGNAL_COMBINATION     = 1;
extern int     _STOPLOSS_COMBINATION         = 1;  //3
extern int     _TRAILING_STOPLOSS_COMBINATION= 1;  //3

/*
string poznamka1 = "0 - vyber timeframe podla dropdown menu - premenna _STRATEGY_TIMEFRAME sa ignoruje";
string poznamka2 = "1 - vyber timeframe podla kodu timeframe 1 - 9";
int   _STRATEGY_TIMEFRAME_CHOICE    = 0;
int   _STRATEGY_TIMEFRAME           = 1;
*/

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
   for(i = 1; i <= _ALL_STRATEGIES; i++)
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
   for(i = 1; i <= _ALL_STRATEGIES; i++)
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
      if(STOPLOSS > 0)
      if(Ask + _MIN_STOPLOSS_DISTANCE*Point < STOPLOSS)
      {
         Print("Bad OrderOpen() STOPLOSS defined. Price Bid was: ", Ask, " and STOPLOSS was: ", STOPLOSS, " . STOPLOSS set to minimal value: ", Bid + _MIN_STOPLOSS_DISTANCE*Point);
         STOPLOSS = Ask + _MIN_STOPLOSS_DISTANCE*Point;
      }
      if(TAKEPROFIT > 0)
      if(Bid - _MIN_TAKEPROFIT_DISTANCE*Point > TAKEPROFIT)
      {
         Print("Bad OrderOpen() TAKEPROFIT defined. Price Bid was: ", Bid, " and TAKEPROFIT was: ", TAKEPROFIT, " . TAKEPROFIT set to minimal value: ", Bid - _MIN_TAKEPROFIT_DISTANCE*Point);
         TAKEPROFIT = Bid - _MIN_TAKEPROFIT_DISTANCE*Point;
      }
      OrderSend(Symbol(), OP_SELL, LOTS, Bid, SLIPPAGE, STOPLOSS, TAKEPROFIT, StringConcatenate(MAGICNUMBER, ""), MAGICNUMBER, 0, Red);
   }
   else
   {
      if(STOPLOSS > 0)
      if(Bid - _MIN_STOPLOSS_DISTANCE*Point < STOPLOSS)
      {
         Print("Bad OrderOpen() STOPLOSS defined. Price Bid was: ", Bid, " and STOPLOSS was: ", STOPLOSS, " . STOPLOSS set to minimal value: ", Bid - _MIN_STOPLOSS_DISTANCE*Point);
         STOPLOSS = Bid - _MIN_STOPLOSS_DISTANCE*Point;
      }
      if(TAKEPROFIT > 0)
      if(Ask + _MIN_TAKEPROFIT_DISTANCE*Point > TAKEPROFIT)
      {
         Print("Bad OrderOpen() TAKEPROFIT defined. Price Bid was: ", Ask, " and TAKEPROFIT was: ", TAKEPROFIT, " . TAKEPROFIT set to minimal value: ", Bid + _MIN_TAKEPROFIT_DISTANCE*Point);
         TAKEPROFIT = Ask + _MIN_TAKEPROFIT_DISTANCE*Point;
      }
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
      if(STOPLOSS > 0)
      if(Bid - _MIN_STOPLOSS_DISTANCE*Point < STOPLOSS)
      {
         Print("Bad OrderModify() STOPLOSS defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Bid was: ", Bid, " and STOPLOSS was: ", STOPLOSS, " . STOPLOSS set to minimal value: ", Bid - _MIN_STOPLOSS_DISTANCE*Point);
//         STOPLOSS = Bid - _MIN_STOPLOSS_DISTANCE*Point;
      }
      if(TAKEPROFIT > 0)
      if(Ask + _MIN_TAKEPROFIT_DISTANCE*Point > TAKEPROFIT)
      {
         Print("Bad OrderModify() TAKEPROFIT defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Bid was: ", Ask, " and TAKEPROFIT was: ", TAKEPROFIT, " . TAKEPROFIT set to minimal value: ", Ask + _MIN_TAKEPROFIT_DISTANCE*Point);
//         TAKEPROFIT = Bid + _MIN_TAKEPROFIT_DISTANCE*Point;
      }

      if(STOPLOSS > 0)
      if(OrderStopLoss() >= STOPLOSS)
         STOPLOSS = OrderStopLoss();
//      if(OrderTakeProfit() <= TAKEPROFIT)
//         TAKEPROFIT = OrderStopLoss();
   }
   if(OrderType() == OP_SELL)
   {
      if(STOPLOSS > 0)
      if(Ask + _MIN_STOPLOSS_DISTANCE*Point > STOPLOSS)
      {
         Print("Bad OrderModify() STOPLOSS defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Ask was: ", Ask, " and STOPLOSS was: ", STOPLOSS, " . STOPLOSS set to minimal value: ", Ask + _MIN_STOPLOSS_DISTANCE*Point);
//         STOPLOSS = Ask + _MIN_STOPLOSS_DISTANCE*Point;
      }
      if(TAKEPROFIT > 0)
      if(Bid - _MIN_TAKEPROFIT_DISTANCE*Point < TAKEPROFIT)
      {
         Print("Bad OrderModify() TAKEPROFIT defined for order ticket: ", OrderTicket(), " and Magic number: ", OrderMagicNumber(), " . Price Ask was: ", Bid, " and TAKEPROFIT was: ", TAKEPROFIT, " . TAKEPROFIT set to minimal value: ", Bid - _MIN_TAKEPROFIT_DISTANCE*Point);
//         TAKEPROFIT = Ask - _MIN_TAKEPROFIT_DISTANCE*Point;
      }

      if(STOPLOSS > 0)
      if(OrderStopLoss() <= STOPLOSS)
         return;
//      if(OrderTakeProfit() >= TAKEPROFIT)
//         TAKEPROFIT = OrderStopLoss();
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
int getHigherTimeframe(int Timeframe)
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
//------------------------------------------------------------------
int getLowerTimeframe(int Timeframe)
{
   switch(Timeframe)
   {
      case PERIOD_M1:
         return (PERIOD_M1);
      case PERIOD_M5:
         return (PERIOD_M1);
      case PERIOD_M15:
         return (PERIOD_M5);
      case PERIOD_M30:
         return (PERIOD_M15);
      case PERIOD_H1:
         return (PERIOD_M30);
      case PERIOD_H4:
         return (PERIOD_H1);
      case PERIOD_D1:
         return (PERIOD_H4);
      case PERIOD_W1:
         return (PERIOD_D1);
      case PERIOD_MN1:
         return (PERIOD_W1);
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
// ZIGZAG breakout system
   if(_STRATEGY == Strategy_023(_GET_STRATEGY_NUMBER))
      return(Strategy_023(_COMMAND));
// ZIGZAG retracement system
   if(_STRATEGY == Strategy_024(_GET_STRATEGY_NUMBER))
      return(Strategy_024(_COMMAND));

   return(0);
}
//------------------------------------------------------------------//------------------------------------------------------------------
double Strategy_023(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 23;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   UpperZIGZAG1;
   double   LowerZIGZAG1;
   double   UpperZIGZAG2;
   double   LowerZIGZAG2;

   double   result         = 0;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         
         if(Ask > getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
      }
      case _OPEN_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

         if(Bid < getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false))
             result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

// somarina - spodny ZIGZAG sa ukaze vacsinou ked sme v strate
//         if(Bid < getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false))
//             result = 1;
            
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

// somarina - horny ZIGZAG sa ukaze vacsinou ked sme v strate
//         if(Ask > getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true))
//            result = 1;
            
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);
         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);
         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
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
         double breakeven = 0;
               
         OrderSelect(0, SELECT_BY_POS);
         if(OrderMagicNumber() != _MAGICNUMBER)
            break;
//            if(OrderProfit() > 0)
         {
            if(OrderType() == OP_BUY)
            {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
               result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
      
               if(result <= OrderStopLoss())
                  result = OrderStopLoss();
            }
            else
            {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
               result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
      
               if(result >= OrderStopLoss())
                  result = OrderStopLoss();
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
double Strategy_024(int _COMMAND)
{
   int      _STRATEGY_NUMBER  = 24;
   int      _MAGICNUMBER      = _STRATEGY_NUMBER;

   string   _SYMBOL        = Symbol();
   int      _TIMEFRAME     = getStrategyTimeframeByNumber(_STRATEGY_TIMEFRAME);
         
   double   UpperZIGZAG1;
   double   LowerZIGZAG1;
   double   UpperZIGZAG2;
   double   LowerZIGZAG2;

   double   result         = 0;
   
   int      i;

   switch(_COMMAND)
   {
      case _OPEN_LONG:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         
         if(Ask < getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true))
            result = 1;

         break;
      }
      case _OPEN_SHORT:
      {
//         break;

//         if(!OpenNewBar(_TIMEFRAME))
//            break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

         if(Bid > getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false))
             result = 1;

         break;
      }
      case _CLOSE_LONG:
      {
         break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

// somarina - spodny ZIGZAG sa ukaze vacsinou ked sme v strate
//         if(Bid < getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false))
//             result = 1;
            
         break;
      }
      case _CLOSE_SHORT:
      {
         break;

         UpperZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         UpperZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, true);
         LowerZIGZAG1 = getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, false);
         LowerZIGZAG2 = getPreviousZIGZAGValue(_SYMBOL, _TIMEFRAME, false);

// somarina - horny ZIGZAG sa ukaze vacsinou ked sme v strate
//         if(Ask > getLastZIGZAGValue(_SYMBOL, _TIMEFRAME, true))
//            result = 1;
            
         break;
      }
      case _GET_LONG_STOPLOSS_PRICE:
      {
//         result = iLow(_SYMBOL, _TIMEFRAME, 1);
         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
         break;
      }
      case _GET_SHORT_STOPLOSS_PRICE:
      {
//         result = iHigh(_SYMBOL, _TIMEFRAME, 1);
         result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
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
         double breakeven = 0;
               
         OrderSelect(0, SELECT_BY_POS);
         if(OrderMagicNumber() != _MAGICNUMBER)
            break;
//            if(OrderProfit() > 0)
         {
            if(OrderType() == OP_BUY)
            {
//                  result = iLow(_SYMBOL, _TIMEFRAME, 1);
               result = getLastFractalValue(_SYMBOL, _TIMEFRAME, false);
      
               if(result <= OrderStopLoss())
                  result = OrderStopLoss();
            }
            else
            {
//                  result = iHigh(_SYMBOL, _TIMEFRAME, 1);
               result = getLastFractalValue(_SYMBOL, _TIMEFRAME, true);
      
               if(result >= OrderStopLoss())
                  result = OrderStopLoss();
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