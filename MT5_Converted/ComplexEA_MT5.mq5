//+------------------------------------------------------------------+
//|                                                 ComplexEA_MT5.mq5 |
//|                                     Copyright 2024, MetaQuotes  |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes"
#property link      "http://www.mql5.com"
#property version   "1.00"

//--- Include MT5 trade library
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

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

//--- MT5 Trade objects
CTrade trade;
CPositionInfo positionInfo;
COrderInfo orderInfo;

//--- Moving average handles
int ma20_handle;
int ma50_handle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("Complex EA MT5 initialized");
    
    // Set up trade object
    trade.SetExpertMagicNumber(MagicNumber);
    trade.SetDeviationInPoints(3);
    
    // Initialize moving average indicators
    ma20_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    ma50_handle = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
    
    if (ma20_handle == INVALID_HANDLE || ma50_handle == INVALID_HANDLE)
    {
        Print("Failed to create indicator handles");
        return(INIT_FAILED);
    }
    
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
    Print("Complex EA MT5 deinitialized, reason: ", reason);
    
    // Release indicator handles
    if (ma20_handle != INVALID_HANDLE)
        IndicatorRelease(ma20_handle);
    if (ma50_handle != INVALID_HANDLE)
        IndicatorRelease(ma50_handle);
    
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
        // Count current positions
        g_OrderCount = CountPositions();
        
        if (g_OrderCount < MaxOrders)
        {
            if (signal > 0)
                OpenBuyPosition();
            else if (signal < 0)
                OpenSellPosition();
        }
    }
    
    // Manage existing positions
    ManageOpenPositions();
    
    // Handle pending orders
    ManagePendingOrders();
}

//+------------------------------------------------------------------+
//| Check if it's time to trade                                     |
//+------------------------------------------------------------------+
bool IsTradeTime()
{
    MqlDateTime dt;
    TimeCurrent(dt);
    return (dt.hour >= TradeHour && dt.hour < TradeHour + 8);
}

//+------------------------------------------------------------------+
//| Get trading signal                                              |
//+------------------------------------------------------------------+
int GetTradingSignal()
{
    // Get moving average values
    double ma20[], ma50[];
    
    if (CopyBuffer(ma20_handle, 0, 0, 1, ma20) <= 0 ||
        CopyBuffer(ma50_handle, 0, 0, 1, ma50) <= 0)
    {
        Print("Failed to get indicator values");
        return 0;
    }
    
    // Get current price
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick))
    {
        Print("Failed to get tick data");
        return 0;
    }
    
    double currentPrice = tick.last;
    
    // Avoid frequent trades
    if (TimeCurrent() - g_LastTradeTime < 300) // 5 minutes
        return 0;
    
    if (ma20[0] > ma50[0] && currentPrice > ma20[0])
        return 1;  // Buy signal
    else if (ma20[0] < ma50[0] && currentPrice < ma20[0])
        return -1; // Sell signal
    
    return 0; // No signal
}

//+------------------------------------------------------------------+
//| Open buy position                                               |
//+------------------------------------------------------------------+
void OpenBuyPosition()
{
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick))
    {
        Print("Failed to get tick data");
        return;
    }
    
    double price = tick.ask;
    double sl = (StopLoss > 0) ? price - StopLoss * _Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price + TakeProfit * _Point * 10 : 0;
    
    if (trade.Buy(LotSize, _Symbol, price, sl, tp, "Complex EA Buy"))
    {
        Print("Buy position opened at: ", price);
        g_LastTradeTime = TimeCurrent();
        
        // Update global variables
        double trades = GlobalVariableGet(GlobalVarPrefix + "TotalTrades");
        GlobalVariableSet(GlobalVarPrefix + "TotalTrades", trades + 1);
    }
    else
    {
        Print("Failed to open buy position, error: ", trade.ResultRetcode());
    }
}

//+------------------------------------------------------------------+
//| Open sell position                                              |
//+------------------------------------------------------------------+
void OpenSellPosition()
{
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick))
    {
        Print("Failed to get tick data");
        return;
    }
    
    double price = tick.bid;
    double sl = (StopLoss > 0) ? price + StopLoss * _Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price - TakeProfit * _Point * 10 : 0;
    
    if (trade.Sell(LotSize, _Symbol, price, sl, tp, "Complex EA Sell"))
    {
        Print("Sell position opened at: ", price);
        g_LastTradeTime = TimeCurrent();
        
        // Update global variables
        double trades = GlobalVariableGet(GlobalVarPrefix + "TotalTrades");
        GlobalVariableSet(GlobalVarPrefix + "TotalTrades", trades + 1);
    }
    else
    {
        Print("Failed to open sell position, error: ", trade.ResultRetcode());
    }
}

//+------------------------------------------------------------------+
//| Count positions with magic number                               |
//+------------------------------------------------------------------+
int CountPositions()
{
    int count = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
                count++;
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Manage open positions (trailing stop, etc.)                    |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
            {
                if (UseTrailingStop)
                    ApplyTrailingStop();
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Apply trailing stop                                             |
//+------------------------------------------------------------------+
void ApplyTrailingStop()
{
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick))
        return;
    
    double newSL = 0;
    
    if (positionInfo.PositionType() == POSITION_TYPE_BUY)
    {
        newSL = tick.bid - TrailingDistance * _Point * 10;
        if (newSL > positionInfo.StopLoss() && newSL < tick.bid)
        {
            if (!trade.PositionModify(positionInfo.Ticket(), newSL, positionInfo.TakeProfit()))
            {
                Print("Failed to modify buy position trailing stop, error: ", trade.ResultRetcode());
            }
        }
    }
    else if (positionInfo.PositionType() == POSITION_TYPE_SELL)
    {
        newSL = tick.ask + TrailingDistance * _Point * 10;
        if ((positionInfo.StopLoss() == 0 || newSL < positionInfo.StopLoss()) && newSL > tick.ask)
        {
            if (!trade.PositionModify(positionInfo.Ticket(), newSL, positionInfo.TakeProfit()))
            {
                Print("Failed to modify sell position trailing stop, error: ", trade.ResultRetcode());
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
        if (orderInfo.SelectByIndex(i))
        {
            if (orderInfo.Symbol() == _Symbol && orderInfo.Magic() == MagicNumber)
            {
                // Example: Cancel old pending orders
                if (TimeCurrent() - orderInfo.TimeSetup() > 3600) // 1 hour
                {
                    if (!trade.OrderDelete(orderInfo.Ticket()))
                    {
                        Print("Failed to delete pending order, error: ", trade.ResultRetcode());
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
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
        {
            if (positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
            {
                totalProfit += positionInfo.Profit() + positionInfo.Swap() + positionInfo.Commission();
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
    GlobalVariableSet(GlobalVarPrefix + "OrderCount", CountPositions());
}

//+------------------------------------------------------------------+
//| Place pending buy stop order                                   |
//+------------------------------------------------------------------+
void PlaceBuyStopOrder(double price)
{
    double sl = (StopLoss > 0) ? price - StopLoss * _Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price + TakeProfit * _Point * 10 : 0;
    
    if (trade.BuyStop(LotSize, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "Complex EA Buy Stop"))
    {
        Print("Buy stop order placed at price: ", price);
    }
    else
    {
        Print("Failed to place buy stop order, error: ", trade.ResultRetcode());
    }
}

//+------------------------------------------------------------------+
//| Place pending sell stop order                                  |
//+------------------------------------------------------------------+
void PlaceSellStopOrder(double price)
{
    double sl = (StopLoss > 0) ? price + StopLoss * _Point * 10 : 0;
    double tp = (TakeProfit > 0) ? price - TakeProfit * _Point * 10 : 0;
    
    if (trade.SellStop(LotSize, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "Complex EA Sell Stop"))
    {
        Print("Sell stop order placed at price: ", price);
    }
    else
    {
        Print("Failed to place sell stop order, error: ", trade.ResultRetcode());
    }
}

//+------------------------------------------------------------------+
//| Handle trade events                                             |
//+------------------------------------------------------------------+
void OnTrade()
{
    // This function is called when trade events occur
    // You can add custom logic here to handle trade events
    UpdateGlobalVariables();
}

//+------------------------------------------------------------------+
//| Handle timer events                                             |
//+------------------------------------------------------------------+
void OnTimer()
{
    // This function can be used for periodic tasks
    // EventSetTimer() should be called in OnInit() to enable timer
    UpdateGlobalVariables();
}