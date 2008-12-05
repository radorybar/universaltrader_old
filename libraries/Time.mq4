#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property library
 
#import "kernel32.dll"
void GetLocalTime(int& TimeArray[]);
void GetSystemTime(int& TimeArray[]);
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

string FormatDateTime(int nYear,int nMonth,int nDay,int nHour,int nMin,int nSec)
  {
   string sMonth,sDay,sHour,sMin,sSec;
//----
   sMonth=100+nMonth;
   sMonth=StringSubstr(sMonth,1);
   sDay=100+nDay;
   sDay=StringSubstr(sDay,1);
   sHour=100+nHour;
   sHour=StringSubstr(sHour,1);
   sMin=100+nMin;
   sMin=StringSubstr(sMin,1);
   sSec=100+nSec;
   sSec=StringSubstr(sSec,1);
//----
   return(StringConcatenate(nYear,".",sMonth,".",sDay," ",sHour,":",sMin,":",sSec));
  }
//+------------------------------------------------------------------+

datetime GetTimeLocal()
{
   int    TimeArray[4];
   int    nYear,nMonth,nDay,nHour,nMin,nSec;
   
   
   GetLocalTime(TimeArray);

   nYear=TimeArray[0]&0x0000FFFF;
   nMonth=TimeArray[0]>>16;
   nDay=TimeArray[1]>>16;
   nHour=TimeArray[2]&0x0000FFFF;
   nMin=TimeArray[2]>>16;
   nSec=TimeArray[3]&0x0000FFFF;
   
   string st = FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
   datetime d = StrToTime(st);
   return(d);
}
datetime GetTimeGMT()
{
   int    TimeArray[4];
   int    nYear,nMonth,nDay,nHour,nMin,nSec;
   int    TZInfoArray[43];

   
   GetLocalTime(TimeArray);

   nYear=TimeArray[0]&0x0000FFFF;
   nMonth=TimeArray[0]>>16;
   nDay=TimeArray[1]>>16;
   nHour=TimeArray[2]&0x0000FFFF;
   nMin=TimeArray[2]>>16;
   nSec=TimeArray[3]&0x0000FFFF;
   
   string st = FormatDateTime(nYear,nMonth,nDay,nHour,nMin,nSec);
   datetime d = StrToTime(st);
   
   
   int gmt_shift=0;
   int ret=GetTimeZoneInformation(TZInfoArray);
   if(ret!=0) gmt_shift=TZInfoArray[0];
   if(ret==2) gmt_shift+=TZInfoArray[42];
   return (d+gmt_shift*60);
}
datetime GetShiftGMT()
{
   double d = (TimeCurrent()-GetTimeGMT());
   return(-3600*MathRound(d/3600));
}