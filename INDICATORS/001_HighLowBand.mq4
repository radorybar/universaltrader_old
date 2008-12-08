//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings

#property  indicator_chart_window
#property  indicator_buffers 2

#property  indicator_color1  Blue
#property  indicator_width1  1

#property  indicator_color2  Red
#property  indicator_width2  1

//---- indicator parameters
extern int  MAPERIOD    = 1;
extern int  MAMETHOD    = MODE_EMA;
//---- indicator buffers
double      PriceHighBuffer[];
double      PriceLowBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorDigits(Digits+1);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(0,PriceHighBuffer);
   SetIndexBuffer(1,PriceLowBuffer);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   
   for(int i=0; i<limit; i++)
   {
      PriceHighBuffer[i] = iMA(NULL, 0, MAPERIOD, 0, MAMETHOD, PRICE_HIGH, i);
      PriceLowBuffer[i] = iMA(NULL, 0, MAPERIOD, 0, MAMETHOD, PRICE_LOW, i);
   }   
      
//---- done
   return(0);
  }
//+------------------------------------------------------------------+