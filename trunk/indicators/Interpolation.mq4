//+------------------------------------------------------------------+
//|                                                Interpolation.mq4 |
//|                                 Copyright © 2008, Gryb Alexander |
//|                ICQ: 478-923-832 E-mail: alexandergrib@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Gryb Alexander"
#property link      "ICQ: 478-923-832 E-mail: alexandergrib@rambler.ru"
#property indicator_separate_window
#property indicator_buffers 1


extern double numPrognoz = 2;
extern int begin=20;
extern int end=25;
double index_buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    SetIndexBuffer(0,index_buffer);
    SetIndexStyle(0,DRAW_LINE);
    ObjectCreate("begin",OBJ_VLINE,0,0,0);
    ObjectSet("begin",OBJPROP_COLOR,Red);
    ObjectCreate("end",OBJ_VLINE,0,0,0);
    ObjectSet("end",OBJPROP_COLOR,Blue);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("begin");
   ObjectDelete("end");
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
    int k; int z; int bar_num; int x;
    double  a = 0; double  b1 = 1;  double  d = 1;
        
    double b[5000];
    double c[5000];
    //Определяем коэфициенты
    for(k=end;k>=begin;k--)
    {
     b[k]=k;
     c[k]=Close[k];
    }
  for(x=begin-numPrognoz;x<end+numPrognoz+1;x++)
  { 
    a = 0;
    for(k=begin;k<=end;k++)
    {      
           b1=1;d=1;
            //Произведение от 0 до i-1 элемента
           for(z=begin;z<k;z++)
           {
              b1=b1*(x-b[z]);
              d=d*(b[k]-b[z]);
           }
           //Произведение от i+1 до numBars элемента
           for(z=k+1;z<=end;z++)
           {
              b1=b1*(x-b[z]);
              d=d*(b[k]-b[z]);
           }
     a=a+c[k]*((b1)/(d));
    }
    bar_num = x;
    index_buffer[bar_num]=a;
  }
  ObjectSet("begin",OBJPROP_TIME1,Time[begin]);
  ObjectSet("end",OBJPROP_TIME1,Time[end]);
//----
   return(0);
  }
//+------------------------------------------------------------------+