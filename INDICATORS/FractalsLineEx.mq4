//+------------------------------------------------------------------+
//|                                                 FractalsLine.mq4 |
//|                               Copyright © 2006, Виктор Чеботарёв |
//|                                      http://www.chebotariov.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Виктор Чеботарёв"
#property link      "http://www.chebotariov.com/"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern string _a = "PERIOD_M1    - 1      - 1 minute.";
extern string _b = "PERIOD_M5    - 5      - 5 minutes.";
extern string _c = "PERIOD_M15   - 15     - 15 minutes.";
extern string _d = "PERIOD_M30   - 30     - 30 minutes.";
extern string _e = "PERIOD_H1    - 60     - 1 hour.";
extern string _f = "PERIOD_H4    - 240    - 4 hour.";
extern string _g = "PERIOD_D1    - 1440   - Daily.";
extern string _h = "PERIOD_W1    - 10080  - Weekly.";
extern string _i = "PERIOD_MN1   - 43200  - Monthly.";
extern string _j = "0 (zero)     - 0      - Timeframe used on the chart.";
extern int _TIMEFRAME = 0;

int _TIMEFRAMES_RATIO = 1;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);

   if(_TIMEFRAME <= Period())
      _TIMEFRAME = Period();
      
   _TIMEFRAMES_RATIO = _TIMEFRAME / Period();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
//----
   int i=Bars-counted_bars-1;
   
   int j=0;
   int start = 0;
   int end = 0;
   
   while(i >= 0)
     {
       if(i == start)
       {
         ExtMapBuffer1[i] = GlobalVariableGet(Symbol() + Period() + "upfrac");
         ExtMapBuffer2[i] = GlobalVariableGet(Symbol() + Period() + "lofrac");
         i--;
         continue;
       }  
       
       start = i;
       j = iBarShift(NULL, _TIMEFRAME, iTime(NULL, Period(), i));
       if(j > 0)
         end = iBarShift(NULL, Period(), iTime(NULL, _TIMEFRAME, j - 1));
       else
         end = 0;
       
       double upfrac_val = iFractals(NULL, _TIMEFRAME, MODE_UPPER, j);
       double lofrac_val = iFractals(NULL, _TIMEFRAME, MODE_LOWER, j);
       
       if(upfrac_val > 0)
           GlobalVariableSet(Symbol() + Period() + "upfrac", upfrac_val);
       else 
           if(lofrac_val > 0)
               GlobalVariableSet(Symbol() + Period() + "lofrac", lofrac_val);

       Print("i: ", i, " j: ", j, " start: ", start, " end: ", end, " counted bars: ", counted_bars);

       i = start;
       while(i > end)
       {
         ExtMapBuffer1[i] = GlobalVariableGet(Symbol() + Period() + "upfrac");
         ExtMapBuffer2[i] = GlobalVariableGet(Symbol() + Period() + "lofrac");
         i--;
       }
     }
//----
   return(0);
  }