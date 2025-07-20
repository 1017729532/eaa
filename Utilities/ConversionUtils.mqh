//+------------------------------------------------------------------+
//|                                            ConversionUtils.mqh  |
//|                                     Copyright 2024, MetaQuotes  |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes"
#property link      "http://www.mql5.com"
#property version   "1.00"

//--- Include necessary MT5 libraries
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//+------------------------------------------------------------------+
//| MT4 to MT5 Conversion Utility Class                            |
//+------------------------------------------------------------------+
class CMT4ToMT5Converter
{
private:
    CTrade            m_trade;
    CPositionInfo     m_positionInfo;
    COrderInfo        m_orderInfo;

public:
    //--- Constructor
    CMT4ToMT5Converter();
    
    //--- Order management conversion functions
    bool              OrderSendMT5(string symbol, ENUM_ORDER_TYPE type, double volume, 
                                  double price, int slippage, double stoploss, 
                                  double takeprofit, string comment, int magic);
    
    bool              OrderSelectMT5(int index, int select_mode);
    bool              OrderModifyMT5(ulong ticket, double price, double stoploss, 
                                    double takeprofit, datetime expiration);
    bool              OrderCloseMT5(ulong ticket, double volume, double price, int slippage);
    bool              OrderDeleteMT5(ulong ticket);
    
    //--- Position information functions
    int               OrdersTotal() { return ::OrdersTotal(); }
    int               PositionsTotal() { return ::PositionsTotal(); }
    
    //--- Convert MT4 order types to MT5
    ENUM_ORDER_TYPE   ConvertOrderType(int mt4_type);
    
    //--- Convert MT4 time constants to MT5
    ENUM_TIMEFRAMES   ConvertTimeframe(int mt4_timeframe);
    
    //--- Price conversion utilities
    double            NormalizePrice(string symbol, double price);
    double            GetPipValue(string symbol);
    
    //--- Global variable compatibility
    bool              GlobalVariableCheck(const string name);
    datetime          GlobalVariableTime(const string name);
    
    //--- Error handling
    string            GetErrorDescription(int error_code);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMT4ToMT5Converter::CMT4ToMT5Converter()
{
    // Initialize trade object with default settings
    m_trade.SetDeviationInPoints(3);
    m_trade.SetTypeFilling(ORDER_FILLING_FOK);
}

//+------------------------------------------------------------------+
//| MT5 equivalent of MT4 OrderSend function                       |
//+------------------------------------------------------------------+
bool CMT4ToMT5Converter::OrderSendMT5(string symbol, ENUM_ORDER_TYPE type, double volume,
                                      double price, int slippage, double stoploss,
                                      double takeprofit, string comment, int magic)
{
    m_trade.SetExpertMagicNumber(magic);
    m_trade.SetDeviationInPoints(slippage);
    
    bool result = false;
    
    switch(type)
    {
        case ORDER_TYPE_BUY:
            result = m_trade.Buy(volume, symbol, price, stoploss, takeprofit, comment);
            break;
            
        case ORDER_TYPE_SELL:
            result = m_trade.Sell(volume, symbol, price, stoploss, takeprofit, comment);
            break;
            
        case ORDER_TYPE_BUY_LIMIT:
            result = m_trade.BuyLimit(volume, price, symbol, stoploss, takeprofit, 
                                     ORDER_TIME_GTC, 0, comment);
            break;
            
        case ORDER_TYPE_SELL_LIMIT:
            result = m_trade.SellLimit(volume, price, symbol, stoploss, takeprofit, 
                                      ORDER_TIME_GTC, 0, comment);
            break;
            
        case ORDER_TYPE_BUY_STOP:
            result = m_trade.BuyStop(volume, price, symbol, stoploss, takeprofit, 
                                    ORDER_TIME_GTC, 0, comment);
            break;
            
        case ORDER_TYPE_SELL_STOP:
            result = m_trade.SellStop(volume, price, symbol, stoploss, takeprofit, 
                                     ORDER_TIME_GTC, 0, comment);
            break;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| MT5 equivalent of MT4 OrderSelect function                     |
//+------------------------------------------------------------------+
bool CMT4ToMT5Converter::OrderSelectMT5(int index, int select_mode)
{
    if (select_mode == SELECT_BY_POS)
    {
        // Try to select as pending order first
        if (m_orderInfo.SelectByIndex(index))
            return true;
        
        // If no pending order, try to select as position
        return m_positionInfo.SelectByIndex(index);
    }
    else if (select_mode == SELECT_BY_TICKET)
    {
        // Try to select as pending order first
        if (m_orderInfo.Select(index))
            return true;
        
        // If no pending order, try to select as position
        return m_positionInfo.SelectByTicket(index);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| MT5 equivalent of MT4 OrderModify function                     |
//+------------------------------------------------------------------+
bool CMT4ToMT5Converter::OrderModifyMT5(ulong ticket, double price, double stoploss,
                                        double takeprofit, datetime expiration)
{
    // Check if it's a pending order
    if (m_orderInfo.Select(ticket))
    {
        return m_trade.OrderModify(ticket, price, stoploss, takeprofit, 
                                  ORDER_TIME_GTC, expiration);
    }
    
    // Check if it's a position
    if (m_positionInfo.SelectByTicket(ticket))
    {
        return m_trade.PositionModify(ticket, stoploss, takeprofit);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| MT5 equivalent of MT4 OrderClose function                      |
//+------------------------------------------------------------------+
bool CMT4ToMT5Converter::OrderCloseMT5(ulong ticket, double volume, double price, int slippage)
{
    if (m_positionInfo.SelectByTicket(ticket))
    {
        m_trade.SetDeviationInPoints(slippage);
        
        if (volume >= m_positionInfo.Volume())
        {
            // Close entire position
            return m_trade.PositionClose(ticket);
        }
        else
        {
            // Partial close
            return m_trade.PositionClosePartial(ticket, volume);
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| MT5 equivalent of MT4 OrderDelete function                     |
//+------------------------------------------------------------------+
bool CMT4ToMT5Converter::OrderDeleteMT5(ulong ticket)
{
    return m_trade.OrderDelete(ticket);
}

//+------------------------------------------------------------------+
//| Convert MT4 order type constants to MT5                        |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE CMT4ToMT5Converter::ConvertOrderType(int mt4_type)
{
    switch(mt4_type)
    {
        case 0: return ORDER_TYPE_BUY;        // OP_BUY
        case 1: return ORDER_TYPE_SELL;       // OP_SELL
        case 2: return ORDER_TYPE_BUY_LIMIT;  // OP_BUYLIMIT
        case 3: return ORDER_TYPE_SELL_LIMIT; // OP_SELLLIMIT
        case 4: return ORDER_TYPE_BUY_STOP;   // OP_BUYSTOP
        case 5: return ORDER_TYPE_SELL_STOP;  // OP_SELLSTOP
    }
    
    return ORDER_TYPE_BUY; // Default
}

//+------------------------------------------------------------------+
//| Convert MT4 timeframe constants to MT5                         |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CMT4ToMT5Converter::ConvertTimeframe(int mt4_timeframe)
{
    switch(mt4_timeframe)
    {
        case 1:     return PERIOD_M1;
        case 5:     return PERIOD_M5;
        case 15:    return PERIOD_M15;
        case 30:    return PERIOD_M30;
        case 60:    return PERIOD_H1;
        case 240:   return PERIOD_H4;
        case 1440:  return PERIOD_D1;
        case 10080: return PERIOD_W1;
        case 43200: return PERIOD_MN1;
    }
    
    return PERIOD_CURRENT; // Default
}

//+------------------------------------------------------------------+
//| Normalize price according to symbol specification              |
//+------------------------------------------------------------------+
double CMT4ToMT5Converter::NormalizePrice(string symbol, double price)
{
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    return NormalizeDouble(price, digits);
}

//+------------------------------------------------------------------+
//| Get pip value for symbol                                       |
//+------------------------------------------------------------------+
double CMT4ToMT5Converter::GetPipValue(string symbol)
{
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    
    // For most currencies, pip is 0.0001 (4 digits) or 0.01 (2 digits for JPY pairs)
    if (digits == 5 || digits == 3)
        return point * 10; // 5-digit broker
    else
        return point;      // 4-digit broker
}

//+------------------------------------------------------------------+
//| Global variable compatibility check                             |
//+------------------------------------------------------------------+
bool CMT4ToMT5Converter::GlobalVariableCheck(const string name)
{
    return ::GlobalVariableCheck(name);
}

//+------------------------------------------------------------------+
//| Global variable time compatibility                              |
//+------------------------------------------------------------------+
datetime CMT4ToMT5Converter::GlobalVariableTime(const string name)
{
    return ::GlobalVariableTime(name);
}

//+------------------------------------------------------------------+
//| Get error description                                           |
//+------------------------------------------------------------------+
string CMT4ToMT5Converter::GetErrorDescription(int error_code)
{
    switch(error_code)
    {
        case 0:     return "No error";
        case 4756:  return "Invalid trade request";
        case 4757:  return "Request rejected";
        case 4758:  return "Request canceled by trader";
        case 4759:  return "Order placed";
        case 4760:  return "Request executed";
        case 4761:  return "Request executed partially";
        case 4762:  return "Request processing error";
        case 4763:  return "Request timeout";
        case 4764:  return "Invalid price";
        case 4765:  return "Invalid stops";
        case 4766:  return "Invalid volume";
        case 4767:  return "Market is closed";
        case 4768:  return "Insufficient money";
        case 4769:  return "Price changed";
        case 4770:  return "Broker's connection to trading center was lost";
        case 4771:  return "Request is rejected by broker's requote";
        default:    return "Unknown error: " + IntegerToString(error_code);
    }
}