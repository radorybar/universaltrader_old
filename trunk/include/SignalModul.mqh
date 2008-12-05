//+------------------------------------------------------------------+
//|                                                  SignalModul.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"

#define  OPEN_LONG_PSAR_2_002_0        11
#define  OPEN_SHORT_PSAR_2_002_0       12
#define  CLOSE_LONG_PSAR_2_002_0       13
#define  CLOSE_SHORT_PSAR_2_002_0      14

#define  OPEN_LONG_SR_LEVELS           21
#define  OPEN_SHORT_SR_LEVELS          22
#define  CLOSE_LONG_SR_LEVELS          23
#define  CLOSE_SHORT_SR_LEVELS         24

#define  OPEN_LONG_CCI_14_XMIN100_0    31
#define  OPEN_SHORT_CCI_14_X100_0      32
#define  CLOSE_LONG_CCI_14_X100_0      33
#define  CLOSE_SHORT_CCI_14_XMIN100_0  34

//+------------------------------------------------------------------+
// Check the signal for Openning position
// USEINDCATOR    -  alias - name of indicator, to use evaluating result signal
bool CheckSignal (int INDICATOR, string SYMBOL = "", int TIMEFRAME = 0)
{
   bool result = false;

   if(StringLen(SYMBOL) == 0)
      SYMBOL = Symbol();
         
   switch(INDICATOR)
   {
      case OPEN_LONG_PSAR_2_002_0:
      {
         result = _OPEN_LONG_PSAR_2_002_0(SYMBOL, TIMEFRAME);
         break;
      }
      case OPEN_SHORT_PSAR_2_002_0:
      {
         result = _OPEN_SHORT_PSAR_2_002_0(SYMBOL, TIMEFRAME);
         break;
      }
      case CLOSE_LONG_PSAR_2_002_0:
      {
         result = _CLOSE_LONG_PSAR_2_002_0(SYMBOL, TIMEFRAME);
         break;
      }
      case CLOSE_SHORT_PSAR_2_002_0:
      {
         result = _CLOSE_SHORT_PSAR_2_002_0(SYMBOL, TIMEFRAME);
         break;
      }
      case OPEN_LONG_SR_LEVELS:
      {
         result = _OPEN_LONG_SR_LEVELS(SYMBOL, TIMEFRAME);
         break;
      }
      case OPEN_SHORT_SR_LEVELS:
      {
         result = _OPEN_SHORT_SR_LEVELS(SYMBOL, TIMEFRAME);
         break;
      }
      case OPEN_LONG_CCI_14_XMIN100_0:
      {
         result = _OPEN_LONG_CCI_14_XMIN100_0(SYMBOL, TIMEFRAME);
         break;
      }
      case OPEN_SHORT_CCI_14_X100_0:
      {
         result = _OPEN_SHORT_CCI_14_X100_0(SYMBOL, TIMEFRAME);
         break;
      }
      case CLOSE_LONG_CCI_14_X100_0:
      {
         result = _CLOSE_LONG_CCI_14_X100_0(SYMBOL, TIMEFRAME);
         break;
      }
      case CLOSE_SHORT_CCI_14_XMIN100_0:
      {
         result = _CLOSE_SHORT_CCI_14_XMIN100_0(SYMBOL, TIMEFRAME);
         break;
      }
   }
      
   return(result);
}
//+------------------------------------------------------------------+
//
bool _OPEN_LONG_PSAR_2_002_0(string SYMBOL, int TIMEFRAME)
{
   double   _STEP       = 0.02;
   double   _MAXIMUM    = 2;
   int      _SHIFT      = 0;

   bool result = false;
   
   double PSAR = iSAR(SYMBOL, TIMEFRAME, _STEP, _MAXIMUM, _SHIFT);
   if(Ask > PSAR)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _OPEN_SHORT_PSAR_2_002_0(string SYMBOL, int TIMEFRAME)
{
   double   _STEP       = 0.02;
   double   _MAXIMUM    = 2;
   int      _SHIFT      = 0;

   bool result = false;
   
   double PSAR = iSAR(SYMBOL, TIMEFRAME, _STEP, _MAXIMUM, _SHIFT);
   if(Bid < PSAR)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _CLOSE_LONG_PSAR_2_002_0(string SYMBOL, int TIMEFRAME)
{
   double   _STEP       = 0.02;
   double   _MAXIMUM    = 2;
   int      _SHIFT      = 0;

   bool result = false;
   
   double PSAR = iSAR(SYMBOL, TIMEFRAME, _STEP, _MAXIMUM, _SHIFT);
   if(Bid <= PSAR)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _CLOSE_SHORT_PSAR_2_002_0(string SYMBOL, int TIMEFRAME)
{
   double   _STEP       = 0.02;
   double   _MAXIMUM    = 2;
   int      _SHIFT      = 0;

   bool result = false;
   
   double PSAR = iSAR(SYMBOL, TIMEFRAME, _STEP, _MAXIMUM, _SHIFT);
   if(Ask >= PSAR)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _OPEN_LONG_CCI_14_XMIN100_0(string SYMBOL, int TIMEFRAME)
{
   int      _PERIOD     = 14;
   int      _PRICE      = PRICE_CLOSE;
   int      _SHIFT      = 0;

   bool result = false;
   
   double CCI = iCCI(SYMBOL, TIMEFRAME, _PERIOD, _PRICE, _SHIFT);
   if(CCI > -100)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _OPEN_SHORT_CCI_14_X100_0(string SYMBOL, int TIMEFRAME)
{
   int      _PERIOD     = 14;
   int      _PRICE      = PRICE_CLOSE;
   int      _SHIFT      = 0;

   bool result = false;
   
   double CCI = iCCI(SYMBOL, TIMEFRAME, _PERIOD, _PRICE, _SHIFT);
   if(CCI < 100)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _CLOSE_LONG_CCI_14_X100_0(string SYMBOL, int TIMEFRAME)
{
   int      _PERIOD     = 14;
   int      _PRICE      = PRICE_CLOSE;
   int      _SHIFT      = 0;

   bool result = false;
   
   double CCI = iCCI(SYMBOL, TIMEFRAME, _PERIOD, _PRICE, _SHIFT);
   if(CCI > 100)
      result = true;
   
   return(result);
}
//+------------------------------------------------------------------+
//
bool _CLOSE_SHORT_CCI_14_XMIN100_0(string SYMBOL, int TIMEFRAME)
{
   int      _PERIOD     = 14;
   int      _PRICE      = PRICE_CLOSE;
   int      _SHIFT      = 0;

   bool result = false;
   
   double CCI = iCCI(SYMBOL, TIMEFRAME, _PERIOD, _PRICE, _SHIFT);
   if(CCI < -100)
      result = true;
   
   return(result);
}







//+------------------------------------------------------------------+
//
int _OPEN_LONG_SR_LEVELS(string SYMBOL, int TIMEFRAME)
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
//+------------------------------------------------------------------+
//
int _OPEN_SHORT_SR_LEVELS(string SYMBOL, int TIMEFRAME)
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
//+------------------------------------------------------------------+