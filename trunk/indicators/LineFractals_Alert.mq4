//+------------------------------------------------------------------+
//|                                           LineFractals_Alert.mq4 |
//+------------------------------------------------------------------+


#property indicator_chart_window

extern color SupLineColor = Magenta;
extern int   SupLnWidth = 1;
extern color ResLineColor = Aqua;
extern int   ResLnWidth = 1;
extern bool  UseAlert = true;

double   Support,Resistance,LastClose;       
double   PriorSupport,PriorResistance,PriorLastClose;       


bool NewBar()
{
   static datetime lastbar = 0;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return (true);
   }
   else
   {
      return (false);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    ObjectCreate("Support", OBJ_TREND, 0,0,0,0,0);
    ObjectCreate("Resistance", OBJ_TREND, 0,0,0,0,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  ObjectDelete("Support");   
  ObjectDelete("Resistance");   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
  double F1=0, F3=0, F13;
  int    B1, B3, SR=2;
  
  while(F3==0)  
  {
    F13=iFractals(NULL,0,MODE_LOWER,SR);
    if (F13!=0) 
    {
      if      (F1==0){B1=SR; F1=F13;}
      else if (F3==0){B3=SR; F3=F13;}
    }
    SR++; 
  }
    ObjectSet("Support", OBJPROP_TIME1 ,iTime(NULL,0,B3));
    ObjectSet("Support", OBJPROP_TIME2 ,iTime(NULL,0,B1));
    ObjectSet("Support", OBJPROP_PRICE1,iLow(NULL,0,B3));
    ObjectSet("Support", OBJPROP_PRICE2,iLow(NULL,0,B1));
    ObjectSet("Support", OBJPROP_RAY   , True);
    ObjectSet("Support", OBJPROP_COLOR, SupLineColor);
    ObjectSet("Support", OBJPROP_WIDTH, SupLnWidth);

  
//----
  double G1=0, G3=0, G13;
  int    C1, C3, RR=2;
  
  while(G3==0)
  {
    G13=iFractals(NULL,0,MODE_UPPER,RR);
    if (G13!=0) 
    {
      if      (G1==0){C1=RR; G1=G13;}
      else if (G3==0){C3=RR; G3=G13;}
    }
    RR++; 
  }
    ObjectSet("Resistance", OBJPROP_TIME1 ,iTime(NULL,0,C3));
    ObjectSet("Resistance", OBJPROP_TIME2 ,iTime(NULL,0,C1));
    ObjectSet("Resistance", OBJPROP_PRICE1,iHigh(NULL,0,C3));
    ObjectSet("Resistance", OBJPROP_PRICE2,iHigh(NULL,0,C1));
    ObjectSet("Resistance", OBJPROP_RAY   , True);
    ObjectSet("Resistance", OBJPROP_COLOR, ResLineColor);
    ObjectSet("Resistance", OBJPROP_WIDTH, ResLnWidth);
      
//====================================================================
//  Alert if last bar closes outside of trendlines
//====================================================================

Support=ObjectGetValueByShift("Support",1);
Resistance=ObjectGetValueByShift("Resistance",1);
LastClose=iClose(NULL,0,1);
PriorSupport=ObjectGetValueByShift("Support",2);
PriorResistance=ObjectGetValueByShift("Resistance",2);
PriorLastClose=iClose(NULL,0,2);


if (NewBar()==true && (UseAlert) && LastClose<Support && PriorLastClose>=PriorSupport) Alert(Symbol()+" "+Period()+": Support broken @ "+DoubleToStr(Support,Digits)+" - Look to go SHORT");
if (NewBar()==true && (UseAlert) && LastClose>Resistance && PriorLastClose<=PriorSupport) Alert(Symbol()+" "+Period()+": Resistance broken @ "+DoubleToStr(Resistance,Digits)+" - Look to go LONG");


  
//----
   return(0);
  }
//+------------------------------------------------------------------+