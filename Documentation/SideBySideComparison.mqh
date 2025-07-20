//+------------------------------------------------------------------+
//|                                        SideBySideComparison.mqh |
//|                                     Copyright 2024, MetaQuotes  |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

/*
This file demonstrates side-by-side comparison of key MT4 vs MT5 code patterns
for the most common EA conversion scenarios.
*/

//+------------------------------------------------------------------+
//| 1. OPENING BUY POSITIONS                                        |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 
                      Ask - 50*Point, Ask + 100*Point, 
                      "Buy Order", 12345, 0, clrGreen);
if(ticket > 0)
    Print("Buy order opened: ", ticket);
else
    Print("Error: ", GetLastError());

MT5 Version:
============
CTrade trade;
trade.SetExpertMagicNumber(12345);
trade.SetDeviationInPoints(3);

MqlTick tick;
SymbolInfoTick(_Symbol, tick);
double sl = tick.ask - 50 * _Point * 10;
double tp = tick.ask + 100 * _Point * 10;

if(trade.Buy(0.1, _Symbol, tick.ask, sl, tp, "Buy Order"))
    Print("Buy position opened");
else
    Print("Error: ", trade.ResultRetcode());
*/

//+------------------------------------------------------------------+
//| 2. ITERATING THROUGH ORDERS/POSITIONS                          |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(OrderSelect(i, SELECT_BY_POS))
    {
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == 12345)
        {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
                Print("Position: ", OrderTicket(), " Profit: ", OrderProfit());
            }
        }
    }
}

MT5 Version:
============
CPositionInfo positionInfo;

// Iterate through positions
for(int i = PositionsTotal() - 1; i >= 0; i--)
{
    if(positionInfo.SelectByIndex(i))
    {
        if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == 12345)
        {
            Print("Position: ", positionInfo.Ticket(), " Profit: ", positionInfo.Profit());
        }
    }
}

// Iterate through pending orders
COrderInfo orderInfo;
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(orderInfo.SelectByIndex(i))
    {
        if(orderInfo.Symbol() == _Symbol && orderInfo.Magic() == 12345)
        {
            Print("Pending order: ", orderInfo.Ticket());
        }
    }
}
*/

//+------------------------------------------------------------------+
//| 3. MODIFYING STOP LOSS                                         |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(OrderSelect(i, SELECT_BY_POS))
    {
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == 12345 && OrderType() == OP_BUY)
        {
            double newSL = Bid - 30 * Point;
            if(newSL > OrderStopLoss())
            {
                if(!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0))
                    Print("Modify error: ", GetLastError());
            }
        }
    }
}

MT5 Version:
============
CTrade trade;
CPositionInfo positionInfo;

for(int i = PositionsTotal() - 1; i >= 0; i--)
{
    if(positionInfo.SelectByIndex(i))
    {
        if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == 12345 && 
           positionInfo.PositionType() == POSITION_TYPE_BUY)
        {
            MqlTick tick;
            SymbolInfoTick(_Symbol, tick);
            double newSL = tick.bid - 30 * _Point * 10;
            
            if(newSL > positionInfo.StopLoss())
            {
                if(!trade.PositionModify(positionInfo.Ticket(), newSL, positionInfo.TakeProfit()))
                    Print("Modify error: ", trade.ResultRetcode());
            }
        }
    }
}
*/

//+------------------------------------------------------------------+
//| 4. CLOSING POSITIONS                                            |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(OrderSelect(i, SELECT_BY_POS))
    {
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == 12345)
        {
            if(OrderType() == OP_BUY)
            {
                if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3))
                    Print("Close error: ", GetLastError());
            }
            else if(OrderType() == OP_SELL)
            {
                if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3))
                    Print("Close error: ", GetLastError());
            }
        }
    }
}

MT5 Version:
============
CTrade trade;
CPositionInfo positionInfo;

for(int i = PositionsTotal() - 1; i >= 0; i--)
{
    if(positionInfo.SelectByIndex(i))
    {
        if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == 12345)
        {
            if(!trade.PositionClose(positionInfo.Ticket()))
                Print("Close error: ", trade.ResultRetcode());
        }
    }
}
*/

//+------------------------------------------------------------------+
//| 5. PLACING PENDING ORDERS                                      |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
double price = Ask + 20 * Point;
double sl = price - 50 * Point;
double tp = price + 100 * Point;

int ticket = OrderSend(Symbol(), OP_BUYSTOP, 0.1, price, 3, sl, tp, 
                      "Buy Stop", 12345, 0, clrGreen);

MT5 Version:
============
CTrade trade;
MqlTick tick;
SymbolInfoTick(_Symbol, tick);

double price = tick.ask + 20 * _Point * 10;
double sl = price - 50 * _Point * 10;
double tp = price + 100 * _Point * 10;

if(!trade.BuyStop(0.1, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "Buy Stop"))
    Print("Pending order error: ", trade.ResultRetcode());
*/

//+------------------------------------------------------------------+
//| 6. INDICATOR ACCESS                                             |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
// In OnTick() or any function
double ma20 = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
double ma50 = iMA(Symbol(), 0, 50, 0, MODE_SMA, PRICE_CLOSE, 0);

if(ma20 > ma50)
    Print("Bullish signal");

MT5 Version:
============
// In OnInit()
int ma20_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
int ma50_handle = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);

// In OnTick()
double ma20[], ma50[];
if(CopyBuffer(ma20_handle, 0, 0, 1, ma20) > 0 &&
   CopyBuffer(ma50_handle, 0, 0, 1, ma50) > 0)
{
    if(ma20[0] > ma50[0])
        Print("Bullish signal");
}

// In OnDeinit()
IndicatorRelease(ma20_handle);
IndicatorRelease(ma50_handle);
*/

//+------------------------------------------------------------------+
//| 7. TIME AND PRICE ACCESS                                       |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
datetime currentTime = TimeCurrent();
int currentHour = Hour();
double currentPrice = Close[0];
double previousPrice = Close[1];

MT5 Version:
============
datetime currentTime = TimeCurrent();
MqlDateTime dt;
TimeCurrent(dt);
int currentHour = dt.hour;

MqlTick tick;
SymbolInfoTick(_Symbol, tick);
double currentPrice = tick.last;

// For previous bar price, need to use rates
MqlRates rates[];
if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates) == 2)
{
    double previousPrice = rates[0].close; // rates[0] is previous, rates[1] is current
}
*/

//+------------------------------------------------------------------+
//| 8. GLOBAL VARIABLES                                             |
//+------------------------------------------------------------------+

/*
Both MT4 and MT5 use similar syntax for global variables:

// Set global variable
GlobalVariableSet("MyEA_TotalTrades", 10);

// Get global variable
double totalTrades = GlobalVariableGet("MyEA_TotalTrades");

// Check if exists
if(GlobalVariableCheck("MyEA_TotalTrades"))
{
    Print("Variable exists");
}

// Delete global variable
GlobalVariableDel("MyEA_TotalTrades");
*/

//+------------------------------------------------------------------+
//| 9. ERROR HANDLING                                              |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "", 0);
if(ticket < 0)
{
    int error = GetLastError();
    Print("OrderSend failed with error: ", error);
}

MT5 Version:
============
CTrade trade;
if(!trade.Buy(0.1, _Symbol))
{
    uint error = trade.ResultRetcode();
    Print("Buy failed with error: ", error);
    Print("Error description: ", trade.ResultComment());
}
*/

//+------------------------------------------------------------------+
//| 10. SYMBOL INFORMATION                                         |
//+------------------------------------------------------------------+

/*
MT4 Version:
============
string symbol = Symbol();
double point = Point;
int digits = Digits;
double spread = MarketInfo(Symbol(), MODE_SPREAD);

MT5 Version:
============
string symbol = _Symbol;
double point = _Point;
int digits = _Digits;
long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
*/