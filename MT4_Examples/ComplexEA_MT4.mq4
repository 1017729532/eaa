//+------------------------------------------------------------------+
//|                                                 ComplexEA_MT4.mq4 |
//|                                     Copyright 2024, MetaQuotes  |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes"
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

//--- Input parameters
input double   LotSize = 0.1;              // Lot size for trading
input int      MagicNumber = 12345;        // Magic number for orders
input double   StopLoss = 50;              // Stop loss in pips
input double   TakeProfit = 100;           // Take profit in pips
input int      TradeHour = 9;              // Hour to start trading
input int      MaxOrders = 3;              // Maximum simultaneous orders
input bool     UseTrailingStop = true;     // Enable trailing stop
input double   TrailingDistance = 30;      // Trailing stop distance in pips
input string   GlobalVarPrefix = "CEA_";   // Global variable prefix

//--- Global variables
double g_LastPrice = 0;
int g_OrderCount = 0;
datetime g_LastTradeTime = 0;
bool g_TradingEnabled = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("Complex EA MT4 initialized");
    
    // Initialize global variables
    GlobalVariableSet(GlobalVarPrefix + "Initialized", 1);
    GlobalVariableSet(GlobalVarPrefix + "TotalTrades", 0);
    GlobalVariableSet(GlobalVarPrefix + "TotalProfit", 0);
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("Complex EA MT4 deinitialized, reason: ", reason);
    
    // Save current statistics to global variables
    double totalProfit = CalculateTotalProfit();
    GlobalVariableSet(GlobalVarPrefix + "LastProfit", totalProfit);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check if trading is enabled
    if (!g_TradingEnabled) return;
    
    // Check trading time
    if (!IsTradeTime()) return;
    
    // Update global variables
    UpdateGlobalVariables();
    
    // Check for new trading signals
    int signal = GetTradingSignal();
    
    if (signal != 0)
    {
        // Count current orders
        g_OrderCount = CountOrders();
        
        if (g_OrderCount < MaxOrders)
        {
            if (signal > 0)
                OpenBuyOrder();
            else if (signal < 0)
                OpenSellOrder();
        }
    }
    
    // Manage existing orders
    ManageOpenOrders();
    
    // Handle pending orders
    ManagePendingOrders();
}

//+------------------------------------------------------------------+
//| Check if it's time to trade                                     |
//+------------------------------------------------------------------+
bool IsTradeTime()
{
    int currentHour = Hour();
    return (currentHour >= TradeHour && currentHour < TradeHour + 8);
}

//+------------------------------------------------------------------+
//| Get trading signal                                              |
//+------------------------------------------------------------------+
int GetTradingSignal()
{
    // Simple moving average strategy
    double ma20 = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
    double ma50 = iMA(Symbol(), 0, 50, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    double currentPrice = Close[0];
    
    // Avoid frequent trades
    if (TimeCurrent() - g_LastTradeTime < 300) // 5 minutes
        return 0;
    
    if (ma20 > ma50 && currentPrice > ma20)
        return 1;  // Buy signal
    else if (ma20 < ma50 && currentPrice < ma20)
        return -1; // Sell signal
    
    return 0; // No signal
}

//+------------------------------------------------------------------+
//| Open buy order                                                  |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
    double price = Ask;
    double sl = (StopLoss > 0) ? price - StopLoss * Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price + TakeProfit * Point * 10 : 0;
    
    int ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, 
                          "Complex EA Buy", MagicNumber, 0, clrGreen);
    
    if (ticket > 0)
    {
        Print("Buy order opened: ", ticket);
        g_LastTradeTime = TimeCurrent();
        
        // Update global variables
        double trades = GlobalVariableGet(GlobalVarPrefix + "TotalTrades");
        GlobalVariableSet(GlobalVarPrefix + "TotalTrades", trades + 1);
    }
    else
    {
        Print("Failed to open buy order, error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Open sell order                                                 |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
    double price = Bid;
    double sl = (StopLoss > 0) ? price + StopLoss * Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price - TakeProfit * Point * 10 : 0;
    
    int ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, 
                          "Complex EA Sell", MagicNumber, 0, clrRed);
    
    if (ticket > 0)
    {
        Print("Sell order opened: ", ticket);
        g_LastTradeTime = TimeCurrent();
        
        // Update global variables
        double trades = GlobalVariableGet(GlobalVarPrefix + "TotalTrades");
        GlobalVariableSet(GlobalVarPrefix + "TotalTrades", trades + 1);
    }
    else
    {
        Print("Failed to open sell order, error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Count orders with magic number                                  |
//+------------------------------------------------------------------+
int CountOrders()
{
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
                count++;
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Manage open orders (trailing stop, etc.)                       |
//+------------------------------------------------------------------+
void ManageOpenOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    if (UseTrailingStop)
                        ApplyTrailingStop();
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Apply trailing stop                                             |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
{
    double newSL = 0;
    
    if (OrderType() == OP_BUY)
    {
        newSL = Bid - TrailingDistance * Point * 10;
        if (newSL > OrderStopLoss() && newSL < Bid)
        {
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, 
                           OrderTakeProfit(), 0, clrBlue))
            {
                Print("Failed to modify buy order trailing stop, error: ", GetLastError());
            }
        }
    }
    else if (OrderType() == OP_SELL)
    {
        newSL = Ask + TrailingDistance * Point * 10;
        if ((OrderStopLoss() == 0 || newSL < OrderStopLoss()) && newSL > Ask)
        {
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, 
                           OrderTakeProfit(), 0, clrBlue))
            {
                Print("Failed to modify sell order trailing stop, error: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Manage pending orders                                           |
//+------------------------------------------------------------------+
void ManagePendingOrders()
{
    // Check for expired pending orders or modify them based on market conditions
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
                if (OrderType() > OP_SELL) // Pending orders
                {
                    // Example: Cancel old pending orders
                    if (TimeCurrent() - OrderOpenTime() > 3600) // 1 hour
                    {
                        if (!OrderDelete(OrderTicket()))
                        {
                            Print("Failed to delete pending order, error: ", GetLastError());
                        }
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate total profit                                          |
//+------------------------------------------------------------------+
double CalculateTotalProfit()
{
    double totalProfit = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
                totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
            }
        }
    }
    return totalProfit;
}

//+------------------------------------------------------------------+
//| Update global variables                                         |
//+------------------------------------------------------------------+
void UpdateGlobalVariables()
{
    double totalProfit = CalculateTotalProfit();
    GlobalVariableSet(GlobalVarPrefix + "CurrentProfit", totalProfit);
    GlobalVariableSet(GlobalVarPrefix + "LastUpdate", TimeCurrent());
    GlobalVariableSet(GlobalVarPrefix + "OrderCount", CountOrders());
}

//+------------------------------------------------------------------+
//| Place pending buy stop order                                   |
//+------------------------------------------------------------------+
void PlaceBuyStopOrder(double price)
{
    double sl = (StopLoss > 0) ? price - StopLoss * Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price + TakeProfit * Point * 10 : 0;
    
    int ticket = OrderSend(Symbol(), OP_BUYSTOP, LotSize, price, 3, sl, tp, 
                          "Complex EA Buy Stop", MagicNumber, 0, clrGreen);
    
    if (ticket > 0)
    {
        Print("Buy stop order placed: ", ticket, " at price: ", price);
    }
    else
    {
        Print("Failed to place buy stop order, error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Place pending sell stop order                                  |
//+------------------------------------------------------------------+
void PlaceSellStopOrder(double price)
{
    double sl = (StopLoss > 0) ? price + StopLoss * Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price - TakeProfit * Point * 10 : 0;
    
    int ticket = OrderSend(Symbol(), OP_SELLSTOP, LotSize, price, 3, sl, tp, 
                          "Complex EA Sell Stop", MagicNumber, 0, clrRed);
    
    if (ticket > 0)
    {
        Print("Sell stop order placed: ", ticket, " at price: ", price);
    }
    else
    {
        Print("Failed to place sell stop order, error: ", GetLastError());
    }
}