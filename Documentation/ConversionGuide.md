# MT4 to MT5 EA Code Conversion Guide

## Overview

This document provides a comprehensive guide for converting MetaTrader 4 (MT4) Expert Advisor code to MetaTrader 5 (MT5) while preserving all original functionality. The conversion process addresses key differences in order management, trading functions, global variables, and overall architecture.

## Key Differences Between MT4 and MT5

### 1. Order Management System

**MT4 Approach:**
- Uses `OrderSend()`, `OrderSelect()`, `OrderModify()`, `OrderClose()`, `OrderDelete()`
- Single pool for both positions and pending orders
- Orders are referenced by tickets

**MT5 Approach:**
- Uses object-oriented CTrade class
- Separate pools for positions and pending orders
- More structured approach with dedicated classes

### 2. Trading Functions Conversion

| MT4 Function | MT5 Equivalent | Notes |
|--------------|----------------|-------|
| `OrderSend()` | `CTrade::Buy()`, `CTrade::Sell()`, etc. | Multiple functions for different order types |
| `OrderSelect()` | `CPositionInfo::Select()`, `COrderInfo::Select()` | Separate for positions and orders |
| `OrderModify()` | `CTrade::PositionModify()`, `CTrade::OrderModify()` | Different for positions vs orders |
| `OrderClose()` | `CTrade::PositionClose()` | Only for positions |
| `OrderDelete()` | `CTrade::OrderDelete()` | Only for pending orders |
| `OrdersTotal()` | `PositionsTotal()` + `OrdersTotal()` | Separate counts |

### 3. Price Data Access

**MT4:**
```mql4
double price = Close[0];
double ma = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
```

**MT5:**
```mql5
MqlTick tick;
SymbolInfoTick(_Symbol, tick);
double price = tick.last;

int ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
double ma_buffer[];
CopyBuffer(ma_handle, 0, 0, 1, ma_buffer);
double ma = ma_buffer[0];
```

### 4. Symbol and Timeframe Constants

| MT4 | MT5 |
|-----|-----|
| `Symbol()` | `_Symbol` |
| `Point` | `_Point` |
| `PERIOD_M1` (1) | `PERIOD_M1` |
| `PERIOD_H1` (60) | `PERIOD_H1` |

## Step-by-Step Conversion Process

### Step 1: Include Required Libraries

Add these includes at the top of your MT5 EA:

```mql5
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
```

### Step 2: Declare Trading Objects

```mql5
CTrade trade;
CPositionInfo positionInfo;
COrderInfo orderInfo;
```

### Step 3: Initialize Trading Objects

In `OnInit()`:

```mql5
trade.SetExpertMagicNumber(MagicNumber);
trade.SetDeviationInPoints(3);
```

### Step 4: Convert Indicator Initialization

**MT4:**
```mql4
// Indicators are accessed directly
double ma = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
```

**MT5:**
```mql5
// Create indicator handles in OnInit()
int ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);

// Access indicator values in OnTick()
double ma_buffer[];
CopyBuffer(ma_handle, 0, 0, 1, ma_buffer);
double ma = ma_buffer[0];
```

### Step 5: Convert Order Management

#### Opening Orders/Positions

**MT4:**
```mql4
int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, Ask-50*Point, Ask+100*Point, "Buy order", 12345, 0, clrGreen);
```

**MT5:**
```mql5
MqlTick tick;
SymbolInfoTick(_Symbol, tick);
double sl = tick.ask - 50 * _Point * 10;
double tp = tick.ask + 100 * _Point * 10;
bool result = trade.Buy(0.1, _Symbol, tick.ask, sl, tp, "Buy order");
```

#### Modifying Positions

**MT4:**
```mql4
bool result = OrderModify(ticket, OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
```

**MT5:**
```mql5
bool result = trade.PositionModify(ticket, newSL, positionInfo.TakeProfit());
```

#### Closing Positions

**MT4:**
```mql4
bool result = OrderClose(ticket, OrderLots(), Bid, 3, clrRed);
```

**MT5:**
```mql5
bool result = trade.PositionClose(ticket);
```

### Step 6: Convert Order/Position Iteration

**MT4:**
```mql4
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(OrderSelect(i, SELECT_BY_POS))
    {
        if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            // Process order
        }
    }
}
```

**MT5:**
```mql5
// For positions
for(int i = PositionsTotal() - 1; i >= 0; i--)
{
    if(positionInfo.SelectByIndex(i))
    {
        if(positionInfo.Symbol() == _Symbol && positionInfo.Magic() == MagicNumber)
        {
            // Process position
        }
    }
}

// For pending orders
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(orderInfo.SelectByIndex(i))
    {
        if(orderInfo.Symbol() == _Symbol && orderInfo.Magic() == MagicNumber)
        {
            // Process order
        }
    }
}
```

## Common Conversion Patterns

### 1. Order Type Conversion

| MT4 Constant | MT5 Constant |
|--------------|--------------|
| `OP_BUY` | `ORDER_TYPE_BUY` |
| `OP_SELL` | `ORDER_TYPE_SELL` |
| `OP_BUYLIMIT` | `ORDER_TYPE_BUY_LIMIT` |
| `OP_SELLLIMIT` | `ORDER_TYPE_SELL_LIMIT` |
| `OP_BUYSTOP` | `ORDER_TYPE_BUY_STOP` |
| `OP_SELLSTOP` | `ORDER_TYPE_SELL_STOP` |

### 2. Error Handling

**MT4:**
```mql4
int error = GetLastError();
```

**MT5:**
```mql5
uint error = trade.ResultRetcode();
```

### 3. Time Functions

**MT4:**
```mql4
int hour = Hour();
```

**MT5:**
```mql5
MqlDateTime dt;
TimeCurrent(dt);
int hour = dt.hour;
```

## Global Variables

Global variables work similarly in both platforms, but there are some improvements in MT5:

```mql5
// Check if global variable exists
if(GlobalVariableCheck("MyVariable"))
{
    double value = GlobalVariableGet("MyVariable");
}

// Set global variable
GlobalVariableSet("MyVariable", 123.45);

// Get variable creation time
datetime created = GlobalVariableTime("MyVariable");
```

## Best Practices for Conversion

### 1. Use the Conversion Utility Class

The provided `ConversionUtils.mqh` file contains a utility class that simplifies many conversion tasks:

```mql5
#include "Utilities/ConversionUtils.mqh"

CMT4ToMT5Converter converter;

// Use MT4-like syntax with MT5 backend
bool result = converter.OrderSendMT5(_Symbol, ORDER_TYPE_BUY, 0.1, Ask, 3, sl, tp, "Comment", 12345);
```

### 2. Handle Indicator Management

Always create indicator handles in `OnInit()` and release them in `OnDeinit()`:

```mql5
int OnInit()
{
    ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    if(ma_handle == INVALID_HANDLE)
        return INIT_FAILED;
    
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    if(ma_handle != INVALID_HANDLE)
        IndicatorRelease(ma_handle);
}
```

### 3. Price Normalization

Always normalize prices in MT5:

```mql5
double normalizedPrice = NormalizeDouble(price, _Digits);
```

### 4. Event Handlers

MT5 provides additional event handlers that can be useful:

```mql5
void OnTrade()
{
    // Called when trade operations occur
}

void OnTimer()
{
    // Called at timer intervals (must be enabled with EventSetTimer)
}
```

## Testing and Validation

1. **Compile both versions** and ensure no errors
2. **Test in Strategy Tester** with the same historical data
3. **Compare results** to ensure functionality equivalence
4. **Verify all features** work as expected:
   - Order placement and management
   - Stop loss and take profit handling
   - Trailing stops
   - Global variable operations
   - Custom strategy logic

## Common Pitfalls and Solutions

### 1. Point Value Differences

MT4 and MT5 may use different point values for the same symbol:

```mql5
// Get the actual pip value
double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

if(digits == 5 || digits == 3)
    pipValue *= 10; // 5-digit broker
```

### 2. Fill Types

MT5 has different order filling types:

```mql5
trade.SetTypeFilling(ORDER_FILLING_FOK); // Fill or Kill
// or
trade.SetTypeFilling(ORDER_FILLING_IOC); // Immediate or Cancel
```

### 3. Position vs Order Confusion

Remember that MT5 separates positions and orders:
- Use `PositionsTotal()` for open positions
- Use `OrdersTotal()` for pending orders
- Use appropriate selection functions for each

## Files in This Project

1. **MT4_Examples/ComplexEA_MT4.mq4** - Original MT4 EA with complex functionality
2. **MT5_Converted/ComplexEA_MT5.mq5** - Converted MT5 version
3. **Utilities/ConversionUtils.mqh** - Utility functions for conversion
4. **Documentation/ConversionGuide.md** - This comprehensive guide

## Conclusion

Converting MT4 EAs to MT5 requires understanding the architectural differences between the platforms. The key is to map MT4's unified order system to MT5's separated position/order system while leveraging MT5's object-oriented approach for better code organization and maintainability.

This conversion framework provides all the tools and examples needed to successfully migrate complex MT4 EAs to MT5 while preserving full functionality.