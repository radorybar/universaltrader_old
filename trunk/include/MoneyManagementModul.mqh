//+------------------------------------------------------------------+
//|                                         MoneyManagementModul.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"
#property library

#define     _FIXLOTS             1
#define     _FIXPERCENTAGE       2

#define     _MINLOTS             0.1
#define     _MAXLOTS             5

//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
double GetLots(int STRATEGY, int AMOUNT)
{
   double lot, result;

   if(STRATEGY == _FIXLOTS)
      lot = AMOUNT;
   else if(STRATEGY == _FIXPERCENTAGE)
      lot = NormalizeDouble(AccountFreeMargin() * AMOUNT / 1000.0, 1);

   if(lot > AccountFreeMargin() / 1500.0)
      lot = MathFloor(10 * AccountFreeMargin() / 1500.0)/ 10;

   if(lot < _MINLOTS)
      lot = _MINLOTS;
   else if(lot > _MAXLOTS)
      lot = _MAXLOTS;
      
   return(lot);
}
//+------------------------------------------------------------------+