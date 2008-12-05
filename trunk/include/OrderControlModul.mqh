//+------------------------------------------------------------------+
//|                                            OrderControlModul.mq4 |
//|                                                      slacktrader |
//|                                                      slacktrader |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      "slacktrader"

//+------------------------------------------------------------------------------------+
//| Modify positions - Stoploss based on Trailing stop                                            |
//+------------------------------------------------------------------------------------+
void CheckForModifyPosition(int TICKETNUMBER, int STOPLOSS, int TRAILINGSTOP)
{
   OrderSelect(TICKETNUMBER, SELECT_BY_TICKET);
   if(OrderType() == OP_BUY)
   {
      if(TRAILINGSTOP > 0)
         if(Bid - OrderOpenPrice() > Point * TRAILINGSTOP)
           if(OrderStopLoss() < Bid - Point * TRAILINGSTOP)
              OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point*TRAILINGSTOP, OrderTakeProfit(), 0, Blue);
   }
   else if(OrderType() == OP_SELL)
   {
      if(TRAILINGSTOP > 0)
         if(Ask + OrderOpenPrice() < Point * TRAILINGSTOP)
           if(OrderStopLoss() > Ask + Point * TRAILINGSTOP)
              OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point * TRAILINGSTOP, OrderTakeProfit(), 0, Red);
   }
}
//+------------------------------------------------------------------------------------+
//| Modify all positions - Stoploss based on Trailing stop                                            |
//+------------------------------------------------------------------------------------+
void CheckForModifyAllPositions(int MAGICNUMBER, int STOPLOSS, int TRAILINGSTOP)
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
         break;
      if(OrderMagicNumber() != MAGICNUMBER)
         continue;
      
      CheckForModifyPosition(OrderTicket(), STOPLOSS, TRAILINGSTOP);
   }
}
//+------------------------------------------------------------------------------------+
//| Close all positions
//+------------------------------------------------------------------------------------+
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
      OrderTickets2Close[ArraySize(OrderTickets2Close)] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//+------------------------------------------------------------------------------------+
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
      OrderTickets2Close[ArraySize(OrderTickets2Close)] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//+------------------------------------------------------------------------------------+
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
      OrderTickets2Close[ArraySize(OrderTickets2Close)] = OrderTicket();
   }

   ClosePositions(OrderTickets2Close);
}
//+------------------------------------------------------------------------------------+
//| Close positions
//+------------------------------------------------------------------------------------+
void ClosePositions(int OrderTickets2Close[])
{
   int i;
   
   for(i = 0; i < ArraySize(OrderTickets2Close); i++)
   {
      ClosePosition(OrderTickets2Close[i]);
   }
}
//+------------------------------------------------------------------------------------+
//| Close position
//+------------------------------------------------------------------------------------+
void ClosePosition(int OrderTicket2Close)
{
   OrderSelect(OrderTicket2Close, SELECT_BY_TICKET);
   if(OrderType() == OP_SELL)
      OrderClose(OrderTicket(), OrderLots(), Ask, 3, Orange);
   else if(OrderType() == OP_BUY)
      OrderClose(OrderTicket(), OrderLots(), Bid, 3, Orange);
}