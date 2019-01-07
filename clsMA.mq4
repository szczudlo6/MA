//+------------------------------------------------------------------+
//|                                                       MA library |
//|                                            Make your trade SMART |
//|                                     by FOREXALLDAY.wordpress.com |
//+------------------------------------------------------------------+
#property library
#property copyright "MA library"
#property link      "https://forexallday.wordpress.com"
#property version   "1.00"
#property strict

#include <hHelperFunction.mqh>

   int MAPeriod;
   int CandleNumber;
   int order;
   int MagicNumber;
   double StopLoss;
   double StopLossLine;
   
void initMA(double _StopLossLine, int _MAPeriod, int _CandleNumber) export
{
    MAPeriod=_MAPeriod;
    CandleNumber=_CandleNumber;
    StopLossLine=_StopLossLine;
}

double GetMAPrice()
{
   double Price=iMA(Symbol(),Period(),MAPeriod,0,MODE_SMA,PRICE_CLOSE,CandleNumber);
   
   return(Price);
}

bool MACheckPrice() export
{
   double CloseBar;
   double PrevCloseBar;
   double MAPrice;
   bool b=false;
   
   CloseBar = Close[CandleNumber];
   PrevCloseBar=Close[CandleNumber+1];
   MAPrice=GetMAPrice();
   
   if(CloseBar>=MAPrice && PrevCloseBar < MAPrice)
   {
      order=0; //buy
      MagicNumber =(int)CreateMagicNumber();
      StopLoss= MathAbs((((MAPrice-(StopLossLine*Point))-Ask)/Point));
      b=true;  
   }
   else if (CloseBar<=MAPrice && PrevCloseBar >MAPrice)
   {
      order=1; //sell
      MagicNumber =(int)CreateMagicNumber();
      StopLoss= MathAbs((((MAPrice+(StopLossLine*Point))-Bid)/Point));
      b=true;
   }
   
   return(b);
}
int GetOrder() export
{
   return(order);
}
int GetMagicNumber() export
{
   return(MagicNumber);
}
double GetStopLoss() export
{
   return(StopLoss);
}

