//+------------------------------------------------------------------+
//|                             HorizontalLineBreakthroughAlert .mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"

extern int      distance = 10;

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int      counted_bars=IndicatorCounted();
   //----
   double   obj;
   int      i;

   for(i = 0; i < ObjectsTotal(); i++)
   {
      if(ObjectType(ObjectName(i)) == OBJ_HLINE)
         CompareThisLine2CurrentPrice(ObjectName(i));
   }
   //----
   return(0);
}
//+------------------------------------------------------------------+
void CompareThisLine2CurrentPrice(string obj)
{
   CheckLineDistanceFromObject(obj);
}
//+------------------------------------------------------------------+
void CheckLineDistanceFromObject(string obj)
{
   double PriceDistance = MathAbs(ObjectGet(obj, OBJPROP_PRICE1) - (Ask - MarketInfo(NULL, MODE_SPREAD)*Point / 2));
   if(PriceDistance < distance)
   {
      Alert(StringConcatenate(Symbol(), " distance from HL is: ", DoubleToStr((distance - PriceDistance)*Point, 4)));
      PlaySound("alert.wav");
   }
}

