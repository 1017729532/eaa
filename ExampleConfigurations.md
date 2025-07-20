# Example Configuration for Technical Indicators EA

This file provides example configurations for different trading strategies using the Technical Indicators EA.

## Conservative Strategy (Low Risk)
```
// RSI Settings
RSI_Period = 21
RSI_Overbought = 75.0
RSI_Oversold = 25.0

// KDJ Settings  
KDJ_K_Period = 8
KDJ_D_Period = 5
KDJ_Overbought = 85.0
KDJ_Oversold = 15.0

// MACD Settings
MACD_FastEMA = 8
MACD_SlowEMA = 21
MACD_SignalSMA = 5

// Bollinger Bands
BB_Period = 24
BB_Deviation = 2.5

// Divergence
Divergence_Lookback = 15
Divergence_MinStrength = 0.7

// Trading
LotSize = 0.05
StopLoss = 150
TakeProfit = 300
```

## Aggressive Strategy (High Risk)
```
// RSI Settings
RSI_Period = 10
RSI_Overbought = 65.0
RSI_Oversold = 35.0

// KDJ Settings
KDJ_K_Period = 3
KDJ_D_Period = 2
KDJ_Overbought = 75.0
KDJ_Oversold = 25.0

// MACD Settings
MACD_FastEMA = 6
MACD_SlowEMA = 18
MACD_SignalSMA = 4

// Bollinger Bands
BB_Period = 16
BB_Deviation = 1.8

// Divergence
Divergence_Lookback = 8
Divergence_MinStrength = 0.3

// Trading
LotSize = 0.2
StopLoss = 80
TakeProfit = 160
```

## Scalping Strategy (Very Short Term)
```
// RSI Settings
RSI_Period = 7
RSI_Overbought = 60.0
RSI_Oversold = 40.0

// KDJ Settings
KDJ_K_Period = 3
KDJ_D_Period = 2
KDJ_Slowing = 2
KDJ_Overbought = 70.0
KDJ_Oversold = 30.0

// MACD Settings
MACD_FastEMA = 5
MACD_SlowEMA = 13
MACD_SignalSMA = 3

// Bollinger Bands
BB_Period = 12
BB_Deviation = 1.5

// Divergence
Divergence_Lookback = 5
Divergence_MinStrength = 0.2

// Trading
LotSize = 0.1
StopLoss = 50
TakeProfit = 100
```

## Swing Trading Strategy (Medium Term)
```
// RSI Settings
RSI_Period = 28
RSI_Overbought = 80.0
RSI_Oversold = 20.0

// KDJ Settings
KDJ_K_Period = 14
KDJ_D_Period = 7
KDJ_Slowing = 5
KDJ_Overbought = 90.0
KDJ_Oversold = 10.0

// MACD Settings
MACD_FastEMA = 16
MACD_SlowEMA = 35
MACD_SignalSMA = 12

// Bollinger Bands
BB_Period = 30
BB_Deviation = 3.0

// Divergence
Divergence_Lookback = 20
Divergence_MinStrength = 0.8

// Trading
LotSize = 0.15
StopLoss = 200
TakeProfit = 400
```

## Filter Combinations

### Maximum Filtering (All Indicators)
```
Use_RSI_Filter = true
Use_KDJ_Filter = true
Use_MACD_Filter = true
Use_BB_Filter = true
Use_Divergence_Filter = true
```

### Momentum Focus (RSI + KDJ + Divergence)
```
Use_RSI_Filter = true
Use_KDJ_Filter = true
Use_MACD_Filter = false
Use_BB_Filter = false
Use_Divergence_Filter = true
```

### Trend Focus (MACD + BB)
```
Use_RSI_Filter = false
Use_KDJ_Filter = false
Use_MACD_Filter = true
Use_BB_Filter = true
Use_Divergence_Filter = false
```

### Reversal Focus (RSI + BB + Divergence)
```
Use_RSI_Filter = true
Use_KDJ_Filter = false
Use_MACD_Filter = false
Use_BB_Filter = true
Use_Divergence_Filter = true
```

## Timeframe Recommendations

### M1 (1 Minute) - Scalping
- Use smaller periods for all indicators
- Reduce divergence lookback
- Lower stop loss and take profit

### M5 (5 Minutes) - Short Term
- Use default parameters or slightly reduced
- Good for intraday trading

### M15 (15 Minutes) - Medium Term  
- Use default parameters
- Balanced approach for most strategies

### H1 (1 Hour) - Swing Trading
- Increase all periods
- Higher divergence lookback
- Larger stop loss and take profit

### H4 (4 Hours) - Position Trading
- Significantly increase periods
- Use higher overbought/oversold levels
- Maximum divergence settings

## Currency Pair Specific Settings

### Major Pairs (EUR/USD, GBP/USD, USD/JPY)
- Use default settings as baseline
- These pairs have good liquidity and standard behavior

### Minor Pairs (EUR/GBP, AUD/JPY, etc.)
- Increase stop loss due to higher volatility
- Consider wider BB deviation

### Exotic Pairs
- Significantly increase stop loss
- Use more conservative overbought/oversold levels
- Reduce lot size

## Optimization Tips

1. **Use the ParameterOptimizer.mq5 script** to find optimal parameters for your specific symbol and timeframe

2. **Backtest thoroughly** before live trading with any configuration

3. **Start with conservative settings** and gradually adjust based on performance

4. **Monitor market conditions** - volatile markets may require different parameters

5. **Regular re-optimization** - market conditions change over time

6. **Risk management** - never risk more than you can afford to lose

Remember: Past performance does not guarantee future results. Always test thoroughly and use proper risk management.