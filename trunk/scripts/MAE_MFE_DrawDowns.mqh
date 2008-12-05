//+------------------------------------------------------------------+
//|                                            MAE_MFE_DrawDowns.mqh |
//|                      Copyright � 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

// ��������� �� ������� SummaryReport
#define OP_BALANCE 6
#define OP_CREDIT  7
#define StatParameters 8
// ��������� �� ������� SummaryReport
#property show_inputs
extern int MaxTimeMissed=15;   // ����������� ���������� ���� � ����������� ������� � �������
//+------------------------------------------------------------------+
//| ��������� ������� MAE � ������ ��������                          |
//+------------------------------------------------------------------+
bool SetMAEAndMFE(double & MFE_Array[],double & MAE_Array[],int TicketsArray[])   
   {
   bool res=false;
//----
   int bar,PeriodNumber,i,limit=ArraySize(TicketsArray);
   ArrayResize(MAE_Array,limit);
   ArrayResize(MFE_Array,limit);
   int openShift,closeShift;
   int type,znak,spread,K_spread;
   double symPoint;
   double MFE_points,MAE_points;
   double currProfit,currLoss,closePriceProfit,closePriceLoss;
   double buy,sell,OPrice,PointCost;
   double deltaPricePoints;
//----
   //Print("����� 1");

   for (i=0;i<limit;i++)
      {
      //Print("�����2");

      if (OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
         {
         openShift=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
         closeShift=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
         //Print("������� ��� ������� MFE �� ������ #",TicketsArray[i]," ���� ",openShift-closeShift," �������� �����, � ����� � ������� ",DoubleToStr((OrderCloseTime()-OrderOpenTime())/60.0,0));
         //if (openShift==-1 || closeShift==-1) Print("�� ������� ������� ��� ������� MFE �� ������ #",TicketsArray[i]);
         type=OrderType();
         OPrice=OrderOpenPrice();
         if (type==OP_BUY) 
            {
            znak=1;
            K_spread=0;
            buy=1;
            sell=0;
            } 
         else 
            {
            znak=-1;
            K_spread=1;
            buy=0;
            sell=1;
            }
         spread=MarketInfo(OrderSymbol(),MODE_SPREAD);
         symPoint=MarketInfo(OrderSymbol(),MODE_POINT);
         //Print("spread=",spread,"   symPoint=",symPoint);
         //if (openShift-closeShift>0)
         MFE_points=-10000;
         MAE_points=-10000;
         deltaPricePoints=(OrderOpenPrice()-OrderClosePrice())/symPoint;
         if (deltaPricePoints==0) 
            {
            //Print("����� ������� �� ���� � ������� SetMAEAndMFE, ������� � ������� ����� ����");
            PointCost=MarketInfo(OrderSymbol(),MODE_POINT)*MarketInfo(OrderSymbol(),MODE_LOTSIZE);
            string first   =StringSubstr(OrderSymbol(),0,3);         // ������ ������,    �������� EUR
            string second  =StringSubstr(OrderSymbol(),3,3);         // ������ ������,    �������� USD
            string currency=AccountCurrency();                // ������ ��������,  �������� USD
            if (second==currency) PointCost=PointCost*OrderLots();
            else
               {
               string crossCurrency=StringConcatenate(second,currency);
               int barCross=iBarShift(crossCurrency,PERIOD_M1,OrderOpenTime());
               double CrossRate=iOpen(crossCurrency,PERIOD_M1,barCross);
               PointCost=PointCost*OrderLots()*CrossRate;
               }
            }
         else PointCost=MathAbs((OrderProfit())/deltaPricePoints);
         //else PointCost=MathAbs((OrderProfit()+OrderSwap())/deltaPricePoints);
         //Print("����� �",TicketsArray[i]," ������ �� ���� ",OPrice);
         for (bar=openShift;bar>=closeShift;bar--)
            {
            //currProfit=(OrderOpenPrice()-Low[bar])*znak-K_spread*spread*symPoint;
            currProfit=(iHigh(OrderSymbol(),PERIOD_M1,bar)-OPrice)*buy-(iLow(OrderSymbol(),PERIOD_M1,bar)+spread*symPoint-OPrice)*sell;
            currLoss=(iLow(OrderSymbol(),PERIOD_M1,bar)-OPrice)*buy-(iHigh(OrderSymbol(),PERIOD_M1,bar)+spread*symPoint-OPrice)*sell;
            if (iHigh(OrderSymbol(),PERIOD_M1,bar)==0) Print("2% ���  ������ #",TicketsArray[i],"  �� ������� ",OrderSymbol()," openShift=",openShift," closeShift=",closeShift,"  �������� � �������� � iHigh(OrderSymbol(),PERIOD_M1,bar) �� ������� ",TimeToStr(iTime(OrderSymbol(),PERIOD_M1,bar)));
            if (iLow(OrderSymbol(),PERIOD_M1,bar)==0) Print("2%���  ������ #",TicketsArray[i],"  �� ������� ",OrderSymbol()," openShift=",openShift," closeShift=",closeShift,"  �������� � �������� � iLow(OrderSymbol(),PERIOD_M1,bar) �� ������� ",TimeToStr(iTime(OrderSymbol(),PERIOD_M1,bar)));

            //Print("currProfit=",currProfit,"   currLoss=",currLoss,"   OPrice=",OPrice);
            //if (currProfit>0 && currProfit/symPoint>MFE_points) 
            if (currProfit/symPoint>MFE_points) 
               {
               MFE_points=currProfit/symPoint;
               //Print("currProfit=",currProfit/symPoint);
               }
            //if (currLoss<0 && -currLoss/symPoint>MAE_points) 
            if ( -currLoss/symPoint>MAE_points) 
               {
               MAE_points=-currLoss/symPoint;
               //Print("currLoss=",currLoss/symPoint);
               }
            }
         MFE_Array[i]=MFE_points*PointCost; 
         MAE_Array[i]=-MAE_points*PointCost;

         if (MathAbs(MFE_Array[i])>10000) Print(OrderSymbol()," #",TicketsArray[i],"; MFE_Array[i]=",MFE_Array[i],"  MFE_points=",MFE_points,"  PointCost=",PointCost,"  symPoint=",symPoint,"  OrderProfit()=",OrderProfit(),"  deltaPrice=",deltaPricePoints);
         if (MathAbs(MAE_Array[i])>10000) Print(OrderSymbol()," #",TicketsArray[i],"; MFA_Array[i]=",MAE_Array[i],"  MAE_points=",MAE_points,"  PointCost=",PointCost,"  symPoint=",symPoint,"  OrderProfit()=",OrderProfit(),"  deltaPrice=",deltaPricePoints);

         //Print("#",TicketsArray[i],";",MFE_Array[i],";",MAE_Array[i]);
         }

      else
         {
         Alert("�� ������� ������� ����� #",TicketsArray[i]);
         }   
      }

//----
   return(res);   
   }   
//+------------------------------------------------------------------+
//|  ��������� ���������� �������� � �������                         |
//+------------------------------------------------------------------+
void    FillOrderProfits(double & ProfitsArray[],double & NormalizedProfitsArray[],double & SwapArray[],int TicketsArray[])
   {
   int total=ArraySize(TicketsArray);
   ArrayResize(ProfitsArray,total);
   ArrayResize(SwapArray,total);
   ArrayResize(NormalizedProfitsArray,total);
//----
   for (int i=0;i<total;i++)
      {
      if (OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
         {
         ProfitsArray[i]=OrderProfit()+OrderSwap()-OrderCommission();
         SwapArray[i]=OrderSwap();
         if (OrderLots()!=0) NormalizedProfitsArray[i]=0.1*ProfitsArray[i]/OrderLots();
         else Alert("��������� ����� � ������� ��������� ���� #",TicketsArray[i]);
         }
      else
         {
         Alert("�� ������� ������� ����� #",TicketsArray[i]);
         }   
      }
//----
   return;   
   }

//+------------------------------------------------------------------+
//| ���������� ��������������� �� �������  �������� ������ �������   |
//+------------------------------------------------------------------+
int LoadSortedTickets(int & Tickets[])
   {
   int i,counter;
   int TicketAndTime[][2];
//----
   if (ArraySize(Tickets)==0) return;
   ArrayResize(TicketAndTime,OrdersHistoryTotal());

   for (i=0;i<OrdersHistoryTotal();i++) 
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         {
            if (OrderType()<=OP_SELL) 
               {
               TicketAndTime[counter][0]=OrderCloseTime();
               TicketAndTime[counter][1]=OrderTicket();
               counter++;
               }
         }
      }
   ArrayResize(TicketAndTime,counter);
   ArrayResize(Tickets,counter);
   if (ArraySize(TicketAndTime)>1) ArraySort(TicketAndTime);
   for (i=0;i<counter;i++) 
      {
      Tickets[i]=TicketAndTime[i][1];
      }
   int err=GetLastError();

//----
   return(counter);
   }
//+------------------------------------------------------------------+
//| ���������� true, ���� ������ � ������ symbolName ��� ����        |
//+------------------------------------------------------------------+
bool AddSymbol(string & SimbolListArray[],string symbolName)
   {
   bool res=false;
   int size=ArraySize(SimbolListArray);
//----
   //Print("��������� ������ ",symbolName);
   ArrayResize(SimbolListArray,size+1);
   if (ArraySize(SimbolListArray)==size+1)
      {
      SimbolListArray[size]=StringTrimLeft(StringTrimRight(symbolName));
      res=true;
      }
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| ���������� true, ���� ������ � ������ symbolName ��� ����        |
//+------------------------------------------------------------------+
bool SymbolFoundInArray(string SimbolListArray[],string symbolName)
   {
   bool res=false;
   int pos;
//----
   for (int i=0;i<ArraySize(SimbolListArray);i++)
      {
      pos=StringFind(SimbolListArray[i],StringTrimLeft(StringTrimRight(symbolName)));
      if (pos!=-1 && pos==0) 
         {
         if (StringLen(SimbolListArray[i])!=StringLen(StringTrimLeft(StringTrimRight(symbolName)))) 
            {
            //Print("����� ������ ������� � ������� ��� �������");
            //Print("������=|",SimbolListArray[i],"| ������=|",symbolName,"|");
            }
         res=true;
         break;
         }
      }
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| ������������ ����� �������� � ���������� �������                 |
//+------------------------------------------------------------------+
bool GetNumberOfOrders(int & Closed,int & Cancelled, string & SymbolsArray[])
   {
   bool res=false;
   Print("������� � ������� ",OrdersHistoryTotal());
//----
   for (int i=OrdersHistoryTotal()-1;i>=0;i--) 
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         {
         if (OrderType()==OP_BALANCE) continue;
            if (!SymbolFoundInArray(SymbolsArray,OrderSymbol())) 
               AddSymbol(SymbolsArray,OrderSymbol());
         if (OrderType()>OP_SELL) Cancelled++;
         else Closed++; 
         }
      }
   if (Cancelled+Closed>0) res=true;   
//----
   return(res);
   }
//+------------------------------------------------------------------+
//| ���������� ������, �� ������� ������� ������ FindName            |
//+------------------------------------------------------------------+
int IndexOfName(string & StringArray[],string FindName)
   {
   int res=-1000;
//----
   int total=ArraySize(StringArray);
   for (int i=0;i<total;i++)
      if (StringArray[i]==FindName)
         {
         res=i;
         break;
         }
//----
   return(res);
   }
//+------------------------------------------------------------------+
//| �������� �������� ������� �� ������� �����                       |
//+------------------------------------------------------------------+
bool    CheckHistoryOnClosedOrders(int & ClosedTicketsArray[],string & SymbolsForClosedOrders[])
   {
   bool res=true;
   int errors[100][3];  // � ������ ������� ����� ������ �������, �� ������ - ����� ������, � ������ - ����/����� ������ 
   int errCounter;      // ������� ������
   int openBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
   int closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
   int TimeInterval[][2];// ������ ������� - ��������� ���� ��������, ������ ������� - �������� ���� ��������
   int indexSymbol;
   datetime timeClose;
//----
   int i,number_orders=ArraySize(ClosedTicketsArray),number_symbols=ArraySize(SymbolsForClosedOrders);
   ArrayResize(TimeInterval,number_symbols);
   for (i=0;i<number_symbols;i++) TimeInterval[i][0]=TimeCurrent();

   for (i=0;i<number_orders;i++)
      {
      if (OrderSelect(ClosedTicketsArray[i],SELECT_BY_TICKET))
         {
         openBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
         if (OrderCloseTime()!=0) closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
         else closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,TimeCurrent());
         indexSymbol=IndexOfName(SymbolsForClosedOrders,OrderSymbol());
         if (MathAbs(iTime(OrderSymbol(),PERIOD_M1,openBar_M1)-OrderOpenTime())/60>MaxTimeMissed)
            {
            errors[errCounter][0]=indexSymbol;
            errors[errCounter][1]=ClosedTicketsArray[i];
            errors[errCounter][2]=OrderOpenTime();
            res=false;
            if (OrderOpenTime()<TimeInterval[indexSymbol][0]) TimeInterval[indexSymbol][0]=OrderOpenTime();
            if (OrderOpenTime()>TimeInterval[indexSymbol][1]) TimeInterval[indexSymbol][1]=OrderOpenTime();
            //Print("������ ��� ������ ���� �������� �� ������� ",OrderSymbol()," M1 ��� ������ #",ClosedTicketsArray[i],"=>",TimeToStr(OrderOpenTime()));
            errCounter++;
            }
         if (OrderCloseTime()!=0) timeClose=OrderCloseTime();
         else timeClose=TimeCurrent();
         if (MathAbs(iTime(OrderSymbol(),PERIOD_M1,closeBar_M1)-timeClose)/60>MaxTimeMissed)
            {
            errors[errCounter][0]=indexSymbol;
            errors[errCounter][1]=ClosedTicketsArray[i];
            errors[errCounter][2]=OrderCloseTime();
            res=false;
            if (OrderCloseTime()<TimeInterval[indexSymbol][0]) TimeInterval[indexSymbol][0]=timeClose;
            if (OrderCloseTime()>TimeInterval[indexSymbol][1]) TimeInterval[indexSymbol][1]=timeClose;
            Print("������ ��� ������ ���� �������� �� ������� ",OrderSymbol()," M1 ��� ������ #",ClosedTicketsArray[i],"=>",TimeToStr(timeClose));
            errCounter++;
            }
         }
      } 

   if (!res) 
      {
      Alert("��� �������� ����� ���������� ������ �������� �������� ����� � ��������� ������� - ",errCounter, "! ����������� ������ � �������� ������");
      for (i=0;i<number_symbols;i++)
         {
         if (TimeInterval[i][0]*TimeInterval[i][1]!=0) Print("�� ������� ������� �� ",SymbolsForClosedOrders[i]," �� ���������:",TimeToStr(TimeInterval[i][0]),"-",TimeToStr(TimeInterval[i][1]));
         }      
      }
//----
   return(res);
   }
//+------------------------------------------------------------------+
//| �������� ��� ��������                                            |
//+------------------------------------------------------------------+
bool CalculateDD(int & ClosedTicketsArray[],string & SymbolsArray[] ,double & minEquity,double & MoneyDD,
   double & MoneyDDPer,double & RelativeDD,double & RelativeDD$)
   {
   bool res=false;
//----
  int AllOpenedOrdersTickets[];           // ������ �������� ������� �� ������� + ������� ���������� ������
  int ConveyerArray[][2];                 // ������� ������� - �����, ������ ������� - �����

   int i,k,marketOrders;
   for (i=0;i<OrdersTotal();i++)
      {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
         if (OrderType()==OP_BUY || OrderType()==OP_SELL) marketOrders++;
         }
      }
   //Print("marketOrders=",marketOrders,",  ������� � �������=",ArraySize(ClosedTicketsArray));
   if (ArraySize(ClosedTicketsArray)+marketOrders==0) 
      {
      Print("��� ������� ��� ���������");
      }
   ArrayResize(AllOpenedOrdersTickets,ArraySize(ClosedTicketsArray)+marketOrders);
   
   i=0;
   if (ArraySize(ClosedTicketsArray)>0) for (i=0;i<ArraySize(ClosedTicketsArray);i++) AllOpenedOrdersTickets[i]=ClosedTicketsArray[i];
   //Print("AllOpenedOrdersTickets=",ArraySize(AllOpenedOrdersTickets));
   if (marketOrders>0)
      {
      while (k<marketOrders) 
         {
         if (OrderSelect(k,SELECT_BY_POS,MODE_TRADES))
            {
            if (OrderType()==OP_BUY || OrderType()==OP_SELL) 
               {
               AllOpenedOrdersTickets[i]=OrderTicket();
               //Print("i=",i,"   k=",k,"  ticket=",OrderTicket());
               if (!SymbolFoundInArray(SymbolsArray,OrderSymbol()))    AddSymbol(SymbolsArray,OrderSymbol()); 
               i++;
               }
            else Alert("��������� ������� ������� �����!!!");               
            }
         k++;
         }
      }
   if (!CheckHistoryOnClosedOrders(AllOpenedOrdersTickets,SymbolsArray))   return(false);
   ArrayResize(ConveyerArray,ArraySize(AllOpenedOrdersTickets)*2);
   //Print("������ ���������=",ArrayRange(ConveyerArray,0));
   for (i=0;i<ArrayRange(AllOpenedOrdersTickets,0);i++)
      {
      //Print("i=",i,"   ticket=",AllOpenedOrdersTickets[i]);
      if (OrderSelect(AllOpenedOrdersTickets[i],SELECT_BY_TICKET))
         {
         //Print("i=",i,"   ticket=",AllOpenedOrdersTickets[i]," OrderOpenTime=",TimeToStr(OrderOpenTime())," OrderCloseTime=",TimeToStr(OrderCloseTime()));
         ConveyerArray[2*i][0]=OrderOpenTime();
         ConveyerArray[2*i][1]=AllOpenedOrdersTickets[i];
         if (OrderCloseTime()!=0) ConveyerArray[2*i+1][0]=OrderCloseTime();
         else ConveyerArray[2*i+1][0]=TimeCurrent()+200;
         ConveyerArray[2*i+1][1]=-AllOpenedOrdersTickets[i];
         }
      else Alert("������ ������ ������ ��� ������� ��������!!!");
      }
   ArraySort(ConveyerArray);      // ����������� �������� �� ������� �������: ��������-�������� ������
   //for (i=0;i<ArrayRange(ConveyerArray,0);i++) Print(TimeToStr(ConveyerArray[i][0])," - ", ConveyerArray[i][1]);
   
   int ticket=OrderSelect(ConveyerArray[0][1],SELECT_BY_TICKET);
   string SymbolName=OrderSymbol();
   int max=ArrayRange(ConveyerArray,0);

   datetime startTrade=TimeRoundeMinute(ConveyerArray[0][0]);
   datetime stopTrade=TimeRoundeMinute(ConveyerArray[max-1][0]);
   if (stopTrade>TimeCurrent()) stopTrade=TimeCurrent();

   double balance=10000;         // ��������� �������� �������� ����� 10 000
   double minimalEquity=balance; // ��������� �������� �������� ����� 10 000
   double lastPeak=balance;      // ��������� �������� ������
   double lastMin=balance;       // ��������� ������� ������
   double equity;                // ������� ������
   double MaxProfit,MinProfit,FixedProfit;
   double currDD, lastmaxDD,currPercentDD,lastPercentDD;
   int curr_pos;
   int stack[];
   datetime curr_minute;
   equity=balance;
   int FileHandle;
//   Print("��������� ���� ",TimeToStr(startTrade,TIME_DATE|TIME_SECONDS),
//      ", �������� ���� ",TimeToStr(stopTrade,TIME_DATE|TIME_SECONDS));
   FileHandle=FileOpen(AccountNumber()+"_equity_2.csv",FILE_CSV|FILE_WRITE);
   FileWrite(FileHandle,"Date","BALANCE","EQUITY");
   FileWrite(FileHandle,TimeToStr(startTrade-1),balance,equity);
   for (curr_minute=startTrade;curr_minute<=stopTrade;curr_minute=curr_minute+60)
      {
      SetStack(stack,ConveyerArray,curr_minute,curr_pos);
      CheckAllProfits(stack,MaxProfit,MinProfit,curr_minute);
      equity=balance+(MaxProfit+MinProfit)/2;
//      Print("balance=",balance);
      if (equity>lastPeak) 
         {
         lastPeak=equity;
         lastMin=equity;
         }
      if (equity<lastMin) 
         {
         lastMin=equity;
         currDD=lastPeak-lastMin;
         if (currDD>lastmaxDD) 
            {
            lastmaxDD=currDD;
            MoneyDDPer=(lastmaxDD)/lastPeak*100;
            MoneyDD=lastmaxDD;
            }
         currPercentDD=currDD/lastPeak*100;
         if (currPercentDD>lastPercentDD)
            {
            lastPercentDD=currPercentDD;
            RelativeDD=lastPercentDD;
            RelativeDD$=currDD;
            }   
         }

      if (lastMin<minimalEquity) 
         {
         minimalEquity=lastMin;
         }
         
      CloseTickets(stack,curr_minute,FixedProfit);
      balance=balance+FixedProfit;
      FileWrite(FileHandle,TimeToStr(curr_minute),balance,equity);
      }
   FileClose(FileHandle);   
   minEquity=minimalEquity;

//----
   return(res);   
   }
//+------------------------------------------------------------------+
//| ������������  ������� �� �������� �������                        |
//+------------------------------------------------------------------+
bool   CheckAllProfits(int stackTickets[],double & maxProfit, double & minProfit,datetime this_minute)
   {
   bool res=false;
   maxProfit=0;
   minProfit=0;
   double thisOrderMaxProfit,thisOrderMinProfit;
//----
   int i,type,pos;
   for (i=0;i<ArraySize(stackTickets);i++)
      {
      if (GetProfit(stackTickets[i],thisOrderMaxProfit,thisOrderMinProfit,this_minute))
         {
         //Print("��������� ������ ��� ������#",stackTickets[i]," � ",TimeToStr(this_minute));
         //Print("thisOrderMaxProfit=",thisOrderMaxProfit,"   thisOrderMinProfit=",thisOrderMinProfit);
         maxProfit+=thisOrderMaxProfit;
         minProfit+=thisOrderMinProfit;
         }
      else Print("�� ������� ���������� ������� ������� ��� ������#",stackTickets[i]);         
      }
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| ���������� ����������� ������������ ������ ��� �������           |
//+------------------------------------------------------------------+
bool GetProfit(int ticket,double & maxProf,double & minProf,datetime at_minute)
   {
   bool res=true;
//----
   string symbol,crossPair,firstCurrency,secondCurrency,baseCurrency=AccountCurrency();
   int bar,type,maxPoint,minPoint,err;
   double openPrice,maxPrice,minPrice,spread,point,pointCost,lots,price;
   datetime foundedTime;
   minProf=0;
   maxProf=0;
   //Print("������� �������� ������� ��� ������#",ticket);
   if (ticket<0) return(res);
   if (OrderSelect(ticket,SELECT_BY_TICKET))
      {
      symbol=OrderSymbol();
      firstCurrency=StringSubstr(OrderSymbol(),0,3);
      secondCurrency=StringSubstr(OrderSymbol(),3,3);
      //Print("base=",baseCurrency,"   firstCurrency=",firstCurrency,"   secondCurrency=",secondCurrency);
      type=OrderType();
      openPrice=OrderOpenPrice();
      bar=iBarShift(symbol,PERIOD_M1,at_minute);
      foundedTime=iTime(symbol,PERIOD_M1,bar);
      spread=MarketInfo(symbol,MODE_SPREAD);
      point=MarketInfo(symbol,MODE_POINT);
      lots=OrderLots();
      if (firstCurrency==baseCurrency)
         {
         price=(iHigh(symbol,PERIOD_M1,bar)+iLow(symbol,PERIOD_M1,bar))/2;
         //Print("price=",price);
         pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)/price;
         }
      if (secondCurrency==baseCurrency)
         {
         pointCost=point*MarketInfo(symbol,MODE_LOTSIZE);
         }
      if (firstCurrency!=baseCurrency && secondCurrency!=baseCurrency)
         {
         //Print("����� ",symbol);
         if (MarketInfo(secondCurrency+baseCurrency,MODE_BID)>0) 
            {
            crossPair=StringConcatenate(secondCurrency,baseCurrency);
            price=(iHigh(crossPair,PERIOD_M1,bar)+iLow(crossPair,PERIOD_M1,bar))/2;
            pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)*price;
            }
         if (MarketInfo(baseCurrency+secondCurrency,MODE_BID)>0) 
            {
            crossPair=StringConcatenate(baseCurrency,secondCurrency);
            price=(iHigh(crossPair,PERIOD_M1,bar)+iLow(crossPair,PERIOD_M1,bar))/2;
            //Print(crossPair,"=",price,"   ",TimeToStr(foundedTime));
            pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)/price;
            }

         err=GetLastError();
         //Print("������ ������� � ���� ",crossPair," M1 � ",TimeToStr(at_minute));
         }   
      //Print("��������� ������  ��� ������#",ticket," ���������� ",pointCost);
         
      if (foundedTime!=TimeRoundeMinute(at_minute)) 
         {
         //Print("������ ��������������� ������� �� ",symbol," M1 � ",TimeToStr(at_minute));
         //Print("        foundedTime=",TimeToStr(foundedTime));
         }
      if (type==OP_BUY)
         {
         maxProf=(iHigh(symbol,PERIOD_M1,bar)-openPrice)/point;
         minProf=(iLow(symbol,PERIOD_M1,bar)-openPrice)/point;
         }
      if (type==OP_SELL)
         {
         maxProf=(openPrice-iHigh(symbol,PERIOD_M1,bar))/point+spread;
         minProf=(openPrice-iLow(symbol,PERIOD_M1,bar))/point+spread;
         }
      maxProf=maxProf*lots*pointCost;
      minProf=minProf*lots*pointCost;
      //Print("maxProf=",maxProf,"   minProf=",minProf," at ",TimeToStr(at_minute));
      }
   else
      {
      res=false;
      Print("�� ������� ������� �����#",ticket," � ",TimeToStr(at_minute),". ������� GetProfit()");
      }     
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//| ������� ������ � ������ ��������� �� �������� �������            |
//+------------------------------------------------------------------+
bool CloseTickets(int & stackTickets[],datetime this_minute,double & fixedProfit)
   {
   bool res=false;
//----
   int i,type,pos,toCloseTickets[];
   int closedCounter;
   fixedProfit=0;
   for (i=0;i<ArraySize(stackTickets);i++)
      {
      if (OrderSelect(stackTickets[i],SELECT_BY_TICKET))
         {
         if (TimeRoundeMinute(OrderCloseTime())==TimeRoundeMinute(this_minute) && stackTickets[i]>=0) 
            {
            fixedProfit=fixedProfit+OrderProfit()+OrderSwap()-OrderCommission();
            AddTicketToClose(toCloseTickets,stackTickets[i]);
            //Print("������� �� ����� �����#",stackTickets[i]," � ",TimeToStr(this_minute));
            closedCounter++;
            }
         }
      }
   if (closedCounter>0)
      {
      res=true;
      for (i=0;i<closedCounter;i++)
         {
         if (!DeleteTicketFromStack(stackTickets,toCloseTickets[i])) Print("������ �������� ������#",toCloseTickets[i]);
         if (!DeleteTicketFromStack(stackTickets,-toCloseTickets[i])) Print("������ �������� ������#",-toCloseTickets[i]);
         }
      GetLastError();
      ArrayResize(toCloseTickets,0);
      if (GetLastError()>0) Print("������ ��� ������� �������� ������� �������");
      }      
//----
   return(res);
   }

//+------------------------------------------------------------------+
//| ������� �� ����� �������� ������                                 |
//+------------------------------------------------------------------+
bool  DeleteTicketFromStack(int & OpenedTicketsArray[],int �lose�Ticket)
   {
   bool res=false;
//----
   int i,pos,size=ArraySize(OpenedTicketsArray);
   for (i=0;i<size;i++)
      {
      if (OpenedTicketsArray[i]==�lose�Ticket)
         {
         pos=i;
         break;
         }
      }
   GetLastError();      
   OpenedTicketsArray[pos]=OpenedTicketsArray[size-1];
   ArrayResize(OpenedTicketsArray,size-1);   // ��������� ��������� ��������
   if (GetLastError()==0) res=true;
//----
   return(res);
   }
   
//+------------------------------------------------------------------+
//|  �������  TicketNumber � ������ Array                            |
//+------------------------------------------------------------------+
bool  AddTicketToClose(int & Array[],int TicketNumber)
   {
   bool res=false;
//----
   GetLastError();
   int size=ArraySize(Array);
   ArrayResize(Array,size+1);
   Array[size]=TicketNumber;
   if (GetLastError()==0) res=true;

//----
   return(res);
   }
//+------------------------------------------------------------------+
//|  �������� �������� �� ������ ������� �������� �������            |
//+------------------------------------------------------------------+
void SetStack(int & stackArray[],int Conveyer[][],datetime this_minute,int & conveyer_pos)
   {
//----
   int i,list=ArrayRange(Conveyer,0);

   while ((TimeRoundeMinute(this_minute)==TimeRoundeMinute(Conveyer[conveyer_pos][0])))
      {
      AddTicketToStack(stackArray,Conveyer[conveyer_pos][1]); 
      //Print("�������� � ���� �����#",Conveyer[conveyer_pos][1]," � ",TimeToStr(this_minute));
      conveyer_pos++;
      }
//----
   return;
   }

//+------------------------------------------------------------------+
//| ������� ������ ����� �������� �������                             |
//+------------------------------------------------------------------+
bool AddTicketToStack(int & stackArray[],int ticket) 
   {
   bool res=false;
//----
   GetLastError();
   int size=ArraySize(stackArray);
   ArrayResize(stackArray,size+1);
   stackArray[size]=ticket;
   if (GetLastError()==0) res=true;
//----
   return(res);   
   }
//+------------------------------------------------------------------+
//|  ���������� ���� � ��������� �� ������                           |
//+------------------------------------------------------------------+
datetime TimeRoundeMinute(datetime input)
   {
   datetime res;
//----
   res=StrToTime(TimeToStr(input,TIME_DATE|TIME_MINUTES));
//----
   return(res);   
   }

//+------------------------------------------------------------------+
//|  ������� ������� ������� � ��������������� MAE � MFE             |
//+------------------------------------------------------------------+
bool WriteMAE_MFE(double MFE_Array[],double MAE_Array[],int TicketsArray[],string FileName)
   {
   bool res=true;
   int i,FH,total=ArraySize(TicketsArray);
   string Line;
//----
   if (total==0) return(false);
   Print("���������� ����� � ������� MAE_MFE ����� ",total);
   FH=FileOpen(FileName,FILE_READ|FILE_WRITE|FILE_CSV); 
   
   if (FH>0)
      {
      FileWrite(FH,"Ticket #","MFE","P&L","MAE","P&L");

      for (i=0;i<total;i++) 
         if (OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
            {
            FileSeek(FH,0,SEEK_END);
            FileWrite(FH,OrderTicket(),MFE_Array[i],OrderProfit(),MAE_Array[i],OrderProfit());
            }
      FileClose(FH);
      }
   else
   {
      Print(GetLastError());
      res=false;
   }
//----
   return(res);
   }
   
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
{
   startCalculate();
}

int startCalculate()
  {
  int ClosedOrders, CancelledOrders;      // ���������� �������� � ���������� �������
  int ClosedTickets[],CancelledTickets[]; // ������, ���������� ������ �������� � ���������� �������
  int AllOpenedOrdersTickets[];           // ������ �������� ������� �� ������� + ������� ���������� ������
  string Symbols[];                       // ������, � ������� �������� ����� ��������, �� ������� ���� ������
  double Swaps[];                         // ����������, �����
  double Profits[],NormalizedProfits[];   // �������, �������� ����������� ������� � ��������������� � 0.1 ����
  double MFE[];                           // ������, ���������� ������ � ������������ ������������� ������� ��� ������� ������
  double MAE[];                           // ������, ���������� ������ � ������������ �������� ��� ������� ������
  double AccountDetails[][9]; 
  double MinimalEquity;                   // ����������� ������������ �������� ������
  double MoneyDrawDown;                   // ������������ �������� ��������
  double MoneyDrawDownInPercent;          // ���������� ��������� ��� ������������ �������� ��������
  double RelativeDrawDown;                // ������������ ���������� ��������
  double RelativeDrawDownInMoney;         // �������� ��������� ������������ ���������� ��������

//----
   
   if (!GetNumberOfOrders(ClosedOrders, CancelledOrders,Symbols))
      {
      Print("������ � ������� �� �������, ��������� ����������");
      }

   ArrayResize(ClosedTickets,ClosedOrders);
   ArrayResize(CancelledTickets,CancelledOrders);
   ArrayResize(AccountDetails,ClosedOrders);
   ArrayResize(Swaps ,ClosedOrders);
  
   LoadSortedTickets(ClosedTickets);
   FillOrderProfits(Profits,NormalizedProfits,Swaps,ClosedTickets);
      
   if (CheckHistoryOnClosedOrders(ClosedTickets,Symbols))   // �������� �� ������� ��� � �������
      {
      SetMAEAndMFE(MFE,MAE,ClosedTickets);                  // � ���� ��� ��� - �������� MAE � MFE
      WriteMAE_MFE(MFE,MAE,ClosedTickets,"MAE_MFE_reports\\"+AccountNumber()+"_MAE_MFE.csv");
//      WriteMAE_MFE(MFE,MAE,ClosedTickets,AccountNumber()+"_MAE_MFE.csv");
      }
   else return;
   
   CalculateDD(ClosedTickets,Symbols,MinimalEquity,MoneyDrawDown,MoneyDrawDownInPercent,RelativeDrawDown,RelativeDrawDownInMoney);
   Print("AbsDD=",10000-MinimalEquity," MoneyDrawDown=",MoneyDrawDown,"  MoneyDrawDownInPercent=",MoneyDrawDownInPercent,
      "  RelativeDrawDown=",RelativeDrawDown," RelativeDrawDownInMoney=",RelativeDrawDownInMoney);
//----
   return(0);
  }
//+------------------------------------------------------------------+