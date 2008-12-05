//+------------------------------------------------------------------+
//|                                                    Calendar2.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern string HtmlAdress = "http://www.dailyfx.com/calendar/Dailyfx_Global_Economic_Calendar.csv";
extern string GetrightAdress = "c:\progra~1\getright\getright.exe";
 
#include <Time.mqh>
#import "kernel32.dll"
int WinExec(string NameEx, int dwFlags);
#import

int Max = 0;
datetime LastTimeDownloading = 0;

void DownloadCalendar()
{
  Print("Downloading "+HtmlAdress+" to experts\files\html\Calendar.csv");
  WinExec(GetrightAdress+" /URL:"+HtmlAdress+" /FILE:Calendar.csv /W /O",0);
}
datetime PerviousMonday(datetime d)
{
  datetime res = d - (TimeDayOfWeek(d)-1)*24*60*60;
  return(res);
}
datetime ToDate(string stDate,string stTime) 
{
  string WeekDay = StringSubstr(stDate,0,3);
  int WeekPlus = 0;
  if (WeekDay=="Mon") WeekPlus=0;
  if (WeekDay=="Tue") WeekPlus=1;
  if (WeekDay=="Wed") WeekPlus=2;
  if (WeekDay=="Thu") WeekPlus=3;
  if (WeekDay=="Fri") WeekPlus=4;
  if (WeekDay=="Sat") WeekPlus=5;
  if (WeekDay=="Sun") WeekPlus=-1;
  
  datetime Res = PerviousMonday(GetTimeGMT())+WeekPlus*24*60*60;
  datetime Tm = StrToTime(stTime);
  Res=Res+TimeHour(Tm )*60*60+TimeMinute(Tm )*60+TimeSeconds(Tm )
         -TimeHour(Res)*60*60-TimeMinute(Res)*60-TimeSeconds(Res);  
  if (StringFind(stTime,"PM")>=0)       
    Res+=12*60*60;
  Res=Res-GetShiftGMT();
  
  return (Res);
}

void GrabNews() 
{
  int file = FileOpen("\calendar\Calendar.csv",FILE_READ|FILE_CSV,',');
  if (file==-1||FileSize(file)==0)
        return;
   
  int i=0;
  while (!FileIsEnding(file))
    {
      string stDate="";
      while (!FileIsEnding(file)&&stDate=="")
        stDate = FileReadString(file);
        
      string stTime = FileReadString(file);
      string stTimeZone = FileReadString(file);
      string stCurrency = FileReadString(file);
      string stDescription = FileReadString(file);
      string stImportance = FileReadString(file);
      string stActual = FileReadString(file);
      string stForecast = FileReadString(file);
      string stPrevious = FileReadString(file);
      
      
      datetime Date = ToDate(stDate,stTime);
      
      color c=Green;
      if (stImportance=="Low") c = Yellow;
      if (stImportance=="Medium") c = Orange;
      if (stImportance=="High") c = Red;
         
      ObjectCreate("CalendarText"+i, OBJ_TEXT, 0, Date, Close[0]);
      ObjectSet("CalendarText"+i, OBJPROP_COLOR, c);          
      ObjectSetText("CalendarText"+i, stDate + " : "+ stDescription, 8);          
      ObjectSet("CalendarText"+i, OBJPROP_ANGLE, 90);          
          
                   
      ObjectCreate("CalendarLine"+i, OBJ_VLINE, 0, Date, Close[0]);
      ObjectSet("CalendarLine"+i, OBJPROP_COLOR, c);                    
      ObjectSet("CalendarLine"+i, OBJPROP_STYLE, STYLE_DOT);                    
      ObjectSet("CalendarLine"+i, OBJPROP_BACK, true);          
      ObjectSetText("CalendarLine"+i, stDescription, 8);                    
      
      i++;
      
    }
  Max = i;
  if (file!=-1)
    FileClose(file);
    
}

void DeleteObjects()
{
   for (int i = 0; i<Max;i++)
     {
      ObjectDelete("CalendarText"+i);
      ObjectDelete("CalendarLine"+i);
     }
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   if (TimeCurrent()>LastTimeDownloading+15*60)
     {
       DeleteObjects();
//       DownloadCalendar();
       LastTimeDownloading = TimeCurrent();
       
       int file=-1;
       while (file==-1)
         file = FileOpen("\calendar\Calendar.csv",FILE_READ|FILE_CSV,',');
       FileClose(file);

       GrabNews();
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+