//Alert if price goes firt time above BB
//Alert only once at each bar
#property copyright           "navodar"
#property link                ""

extern double  BBPeriod = 20;
extern double  BBDev    = 2;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   double            BBH;
   double            BBL;

   static datetime   alertedat = 0;

   if(Bars <= BBPeriod || IsTradeAllowed() == false) 
      return;

//Trade only once on a Bar
   if(alertedat == Time[0]) 
      return;

   RefreshRates();
      
//get BB
   BBH=iCustom(NULL, 0, "Bands", BBPeriod, 0, BBDev, 1, 0);
   BBL=iCustom(NULL, 0, "Bands", BBPeriod, 0, BBDev, 2, 0);

   if(Bid > BBH || Bid < BBL)
   {
      PlaySound("alert.wav");
      alertedat = Time[0];
      Alert(Symbol());
   }
      
   return(0);
}