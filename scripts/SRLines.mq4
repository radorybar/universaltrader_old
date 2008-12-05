//+------------------------------------------------------------------+
//|                                                      SRLines.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"

extern int     _PERIOD  = PERIOD_H1;
extern int     _RANGE   = 600;
extern int     _MAXAGE  = 100;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
{
   double LastUpFractalValue = 0;
   double LastLowFractalValue = 0;
   double UpFractalValue = 0;
   double LowFractalValue = 0;
   
   for(int i = 1; i <= _MAXAGE; i++)
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
   return(0);
}
//+------------------------------------------------------------------+