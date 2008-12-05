//+------------------------------------------------------------------+
//|                                                         Time.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#import "Time.ex4"
datetime GetTimeLocal(); //local time of the computer
datetime GetTimeGMT();   //current time in gmt
datetime GetShiftGMT();  //TimeCurrent()+GetShiftGMT()==GetTimeGMT()
#import
//+------------------------------------------------------------------+