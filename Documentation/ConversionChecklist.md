# MT4 to MT5 EA Conversion Checklist

Use this checklist to ensure complete and accurate conversion of your MT4 EA to MT5.

## Pre-Conversion Analysis

- [ ] **Identify all MT4-specific functions used in the EA:**
  - [ ] OrderSend()
  - [ ] OrderSelect()
  - [ ] OrderModify()
  - [ ] OrderClose()
  - [ ] OrderDelete()
  - [ ] OrdersTotal()
  - [ ] Other order management functions

- [ ] **List all indicators used:**
  - [ ] iMA() - Moving Average
  - [ ] iRSI() - Relative Strength Index
  - [ ] iBands() - Bollinger Bands
  - [ ] iStochastic() - Stochastic
  - [ ] iMACD() - MACD
  - [ ] Custom indicators
  - [ ] Other built-in indicators

- [ ] **Identify time and price access patterns:**
  - [ ] Close[n], Open[n], High[n], Low[n] arrays
  - [ ] Time[n] array
  - [ ] Ask, Bid variables
  - [ ] Point variable
  - [ ] Digits variable

- [ ] **Check for global variables usage:**
  - [ ] GlobalVariableSet()
  - [ ] GlobalVariableGet()
  - [ ] GlobalVariableCheck()
  - [ ] GlobalVariableDel()

## File Setup

- [ ] **Create new MT5 EA file (.mq5 extension)**
- [ ] **Add required #include statements:**
  ```mql5
  #include <Trade\Trade.mqh>
  #include <Trade\PositionInfo.mqh>
  #include <Trade\OrderInfo.mqh>
  ```

- [ ] **Declare global trading objects:**
  ```mql5
  CTrade trade;
  CPositionInfo positionInfo;
  COrderInfo orderInfo;
  ```

## OnInit() Function Conversion

- [ ] **Initialize trade object:**
  ```mql5
  trade.SetExpertMagicNumber(MagicNumber);
  trade.SetDeviationInPoints(SlippagePoints);
  trade.SetTypeFilling(ORDER_FILLING_FOK);
  ```

- [ ] **Create indicator handles for all indicators:**
  ```mql5
  ma_handle = iMA(_Symbol, PERIOD_CURRENT, period, shift, method, price);
  if(ma_handle == INVALID_HANDLE) return INIT_FAILED;
  ```

- [ ] **Initialize any custom variables**
- [ ] **Set up global variables if needed**

## OnDeinit() Function Conversion

- [ ] **Release all indicator handles:**
  ```mql5
  if(ma_handle != INVALID_HANDLE)
      IndicatorRelease(ma_handle);
  ```

- [ ] **Clean up any other resources**

## OnTick() Function Conversion

### Order Management

- [ ] **Convert OrderSend() calls:**
  - [ ] Replace with appropriate CTrade methods:
    - [ ] trade.Buy() for OP_BUY
    - [ ] trade.Sell() for OP_SELL
    - [ ] trade.BuyLimit() for OP_BUYLIMIT
    - [ ] trade.SellLimit() for OP_SELLLIMIT
    - [ ] trade.BuyStop() for OP_BUYSTOP
    - [ ] trade.SellStop() for OP_SELLSTOP

- [ ] **Convert order iteration loops:**
  ```mql5
  // For positions
  for(int i = PositionsTotal() - 1; i >= 0; i--)
  {
      if(positionInfo.SelectByIndex(i))
      {
          // Process position
      }
  }
  
  // For pending orders
  for(int i = OrdersTotal() - 1; i >= 0; i--)
  {
      if(orderInfo.SelectByIndex(i))
      {
          // Process order
      }
  }
  ```

- [ ] **Convert OrderModify() calls:**
  - [ ] Use trade.PositionModify() for positions
  - [ ] Use trade.OrderModify() for pending orders

- [ ] **Convert OrderClose() calls:**
  - [ ] Replace with trade.PositionClose()
  - [ ] Handle partial closes with trade.PositionClosePartial()

- [ ] **Convert OrderDelete() calls:**
  - [ ] Replace with trade.OrderDelete()

### Price and Time Data

- [ ] **Replace direct price access:**
  ```mql5
  // Replace Close[n], Open[n], etc. with:
  MqlRates rates[];
  CopyRates(_Symbol, PERIOD_CURRENT, 0, bars_needed, rates);
  ```

- [ ] **Replace Ask/Bid access:**
  ```mql5
  MqlTick tick;
  SymbolInfoTick(_Symbol, tick);
  double ask = tick.ask;
  double bid = tick.bid;
  ```

- [ ] **Update Point references:**
  ```mql5
  // Replace Point with _Point * 10 for 5-digit brokers
  double sl = price - 50 * _Point * 10;
  ```

### Indicator Access

- [ ] **Convert direct indicator calls:**
  ```mql5
  // Replace iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0) with:
  double ma_buffer[];
  CopyBuffer(ma_handle, 0, 0, 1, ma_buffer);
  double ma_value = ma_buffer[0];
  ```

- [ ] **Update all indicator access patterns**
- [ ] **Ensure proper error checking for CopyBuffer()**

## Error Handling

- [ ] **Replace GetLastError() with trade.ResultRetcode()**
- [ ] **Add proper error checking for all trade operations**
- [ ] **Update error messages and logging**

## Constants and Enums

- [ ] **Update order type constants:**
  - [ ] OP_BUY → ORDER_TYPE_BUY
  - [ ] OP_SELL → ORDER_TYPE_SELL
  - [ ] OP_BUYLIMIT → ORDER_TYPE_BUY_LIMIT
  - [ ] etc.

- [ ] **Update symbol constants:**
  - [ ] Symbol() → _Symbol
  - [ ] Point → _Point
  - [ ] Digits → _Digits

- [ ] **Update timeframe constants if needed**

## Testing Phase

- [ ] **Compile the MT5 EA and fix any errors**
- [ ] **Test in Strategy Tester with historical data**
- [ ] **Compare results with original MT4 EA**
- [ ] **Verify all functionality works correctly:**
  - [ ] Order placement
  - [ ] Position management
  - [ ] Stop loss and take profit handling
  - [ ] Trailing stops
  - [ ] Pending orders
  - [ ] Global variables
  - [ ] Custom logic

## Optimization and Finalization

- [ ] **Optimize code for MT5 architecture**
- [ ] **Add any MT5-specific enhancements:**
  - [ ] OnTrade() event handler
  - [ ] OnTimer() functionality
  - [ ] Better error handling

- [ ] **Update comments and documentation**
- [ ] **Test on demo account before live trading**

## Final Verification

- [ ] **All original functionality preserved**
- [ ] **No compilation errors or warnings**
- [ ] **Strategy Tester results match expectations**
- [ ] **All edge cases handled properly**
- [ ] **Performance is acceptable**

## Additional MT5 Features to Consider

- [ ] **Implement OnTrade() event handler for trade notifications**
- [ ] **Add OnTimer() for periodic tasks**
- [ ] **Use MqlTradeRequest for advanced order handling**
- [ ] **Implement proper money management with AccountInfo functions**
- [ ] **Add symbol-specific settings handling**

## Notes and Custom Modifications

```
Add any project-specific notes or modifications needed:

- Custom indicator conversions:
- Special logic adaptations:
- Performance optimizations:
- Additional features added:
```

---

**Conversion Status:**
- [ ] Analysis Complete
- [ ] Basic Structure Converted
- [ ] Trading Functions Converted  
- [ ] Indicators Converted
- [ ] Testing Complete
- [ ] Final Verification Passed

**Date Started:** ___________
**Date Completed:** ___________
**Tested By:** ___________