 //+-----------------------------------------------------------------+
//|                                                         MA ROBOT |
//|                                            Make your trade SMART |
//|                                     by FOREXALLDAY.wordpress.com |
//+------------------------------------------------------------------+
#property copyright "MA ROBOT"
#property link      "https://forexallday.wordpress.com"
#property version   "1.00"
#property strict

extern int MAPeriod = 33;
extern int CandleNumber=1;
extern double MoneyRisk=2.0;
extern double StopLossLine = 100;

extern double PriceDeviation=20;
extern double TrailingStop = 0;

#include <clsStruct.mqh>
#include <hMA.mqh>
#include <hCandle.mqh>
#include <hOrder.mqh>
#include <hFile.mqh>

int OpenedOrders=0;
int MaxOpenPosition = 1;
string OrderFileName;

int OnInit()
  {
   strGlobal arr[];
   OrderFileName = "MA_ROBOT_"+(string)AccountNumber() + "_"+Symbol()+"_"+(string)Period()+"_Orders.txt";
   
   int CheckOpenPosition=0;
   
   Comment("Account Balance: " + (string)NormalizeDouble(AccountBalance(),2));
   
   //init
   initMA(StopLossLine,MAPeriod,CandleNumber);
   initTimeCandle(CandleNumber);
   initOrder (MoneyRisk,MaxOpenPosition);   
   
   ReinitFile(OrderFileName);
   
   //get open position
   CheckOpenPosition=GetOpenOrder();
   
   if(CheckOpenPosition > OpenedOrders)
      OpenedOrders=CheckOpenPosition;

   GetOrderArrayFromFile(arr);
   SetOrderArrayFromFile(arr);
   
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {   
   if(OpenedOrders==0 && CheckCurrentCandle(CandleNumber))
      if(MACheckPrice())
         if(OpenOrder(OpenedOrders,GetOrder(),0,GetStopLoss(),0,GetMagicNumber()))
         {
            //add magicnumber to file
            if (!AddMagicNumber(GetMagicNumber()))
               Print("Cannot add order to array");
               
            OpenedOrders++;
         }
   else if (OpenedOrders>0)
      CheckCurrentOrders();
   
  }
  
void CheckCurrentOrders()
{  
   int magicnumber=0;
   int b=false;
   
   for (int i=OrdersTotal()-1; i >= 0 ;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         magicnumber = OrderMagicNumber();
         if(CheckMagicNumber(magicnumber))
         {
            b=true;
            Trailing(magicnumber,TrailingStop);
            if(MACheckPrice())
               if(CloseOrderByMagicNumber(magicnumber))
               {
                  OpenedOrders--;
                  ReinitFile(OrderFileName);
               }
         } 
      }
   }
   
   //if order was opened but not exist in server
   if (!b)
      OpenedOrders=0;
}
