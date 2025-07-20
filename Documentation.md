# Technical Indicators EA Documentation

## Overview
This MT5 Expert Advisor (EA) implements a comprehensive trading system using multiple technical indicators as filters for opening the first trade when market conditions align. The EA includes RSI, KDJ (Stochastic), MACD, Bollinger Bands, and divergence detection.

## Features
- **RSI (Relative Strength Index)**: Momentum oscillator for identifying overbought/oversold conditions
- **KDJ (Stochastic Oscillator)**: Momentum indicator comparing closing price to price range over time
- **MACD (Moving Average Convergence Divergence)**: Trend-following momentum indicator
- **Bollinger Bands**: Volatility indicator using standard deviation bands
- **Divergence Detection**: Advanced algorithm detecting price/indicator divergences
- **Flexible Parameters**: All indicator settings are fully configurable
- **One Trade Policy**: Opens only the first trade when all conditions are met

## File Structure
```
/TechnicalIndicatorsEA.mq5          # Main EA file
/Include/
  ├── Divergence.mqh                # Advanced divergence detection class
  └── IndicatorConfig.mqh            # Configuration structures and validation
/Documentation.md                   # This documentation file
```

## Technical Indicators

### 1. RSI (Relative Strength Index)
**Parameters:**
- `RSI_Period`: Period for RSI calculation (default: 14)
- `RSI_AppliedPrice`: Price type for calculation (default: PRICE_CLOSE)
- `RSI_Overbought`: Overbought level (default: 70.0)
- `RSI_Oversold`: Oversold level (default: 30.0)

**Signal Logic:**
- Buy signal: RSI crosses above oversold level
- Sell signal: RSI crosses below overbought level

### 2. KDJ (Stochastic Oscillator)
**Parameters:**
- `KDJ_K_Period`: %K period (default: 5)
- `KDJ_D_Period`: %D period (default: 3)
- `KDJ_Slowing`: Slowing factor (default: 3)
- `KDJ_Method`: Moving average method (default: SMA)
- `KDJ_PriceField`: Price field for calculation (default: STO_LOWHIGH)
- `KDJ_Overbought`: Overbought level (default: 80.0)
- `KDJ_Oversold`: Oversold level (default: 20.0)

**Signal Logic:**
- Buy signal: %K crosses above %D in oversold area
- Sell signal: %K crosses below %D in overbought area

### 3. MACD (Moving Average Convergence Divergence)
**Parameters:**
- `MACD_FastEMA`: Fast EMA period (default: 12)
- `MACD_SlowEMA`: Slow EMA period (default: 26)
- `MACD_SignalSMA`: Signal line SMA period (default: 9)
- `MACD_AppliedPrice`: Price type for calculation (default: PRICE_CLOSE)

**Signal Logic:**
- Buy signal: MACD line crosses above signal line
- Sell signal: MACD line crosses below signal line

### 4. Bollinger Bands
**Parameters:**
- `BB_Period`: Moving average period (default: 20)
- `BB_Shift`: Horizontal shift (default: 0)
- `BB_Deviation`: Standard deviation multiplier (default: 2.0)
- `BB_AppliedPrice`: Price type for calculation (default: PRICE_CLOSE)

**Signal Logic:**
- Buy signal: Price bounces from lower band
- Sell signal: Price bounces from upper band

### 5. Divergence Detection
**Parameters:**
- `Divergence_Lookback`: Bars to analyze for divergence (default: 10)
- `Divergence_MinStrength`: Minimum divergence strength (default: 0.5)

**Signal Logic:**
- Bullish divergence: Price makes lower low, indicator makes higher low
- Bearish divergence: Price makes higher high, indicator makes lower high
- Uses multiple indicators (RSI, MACD, Stochastic) for confirmation

## Trading Parameters
- `LotSize`: Position size (default: 0.1)
- `StopLoss`: Stop loss in points (default: 100)
- `TakeProfit`: Take profit in points (default: 200)
- `MagicNumber`: Unique identifier for EA trades (default: 123456)
- `TradeComment`: Comment for opened trades

## Filter Configuration
Each technical indicator can be individually enabled/disabled:
- `Use_RSI_Filter`: Enable/disable RSI filter
- `Use_KDJ_Filter`: Enable/disable KDJ filter
- `Use_MACD_Filter`: Enable/disable MACD filter
- `Use_BB_Filter`: Enable/disable Bollinger Bands filter
- `Use_Divergence_Filter`: Enable/disable divergence detection

## Signal Logic
The EA uses a majority-based approach:
- Calculates signals from all enabled indicators
- Opens trade when ≥60% of enabled filters agree on direction
- Only opens the first trade per EA instance

## Installation and Usage

### 1. Installation
1. Copy `TechnicalIndicatorsEA.mq5` to your MT5 `Experts` folder
2. Copy the `Include` folder and its contents to your MT5 `Experts` folder
3. Compile the EA in MetaEditor
4. Attach to desired chart

### 2. Configuration
1. Adjust indicator parameters according to your trading strategy
2. Enable/disable specific filters as needed
3. Set appropriate lot size and risk management parameters
4. Configure stop loss and take profit levels

### 3. Monitoring
- EA prints detailed information about signals and trades
- Monitor the Experts tab for EA status and trade information
- Only one trade will be opened per EA instance

## Advanced Features

### Divergence Detection Class
The `CDivergenceDetector` class provides sophisticated divergence analysis:
- Detects divergences across multiple indicators
- Configurable lookback period and minimum strength
- Supports bullish and bearish divergence detection
- Uses pivot point analysis for accurate signal generation

### Configuration Management
The `SIndicatorConfig` structure provides:
- Centralized parameter management
- Input validation for all parameters
- Default value initialization
- Modular configuration approach

## Risk Management
- **Position Sizing**: Use appropriate lot sizes for your account
- **Stop Loss**: Always set stop loss to limit potential losses
- **Take Profit**: Set realistic profit targets
- **One Trade Limit**: EA automatically limits to one trade per instance

## Customization
The EA is designed for easy modification:
- Modular code structure with separate include files
- Clear function separation for each indicator
- Configurable parameters for all technical indicators
- Extensible design for adding new indicators

## Troubleshooting

### Common Issues
1. **Indicator handles invalid**: Check symbol and timeframe compatibility
2. **No trades opening**: Verify filter settings and market conditions
3. **Compilation errors**: Ensure all include files are in correct location

### Debug Information
The EA provides comprehensive logging:
- Initialization success/failure messages
- Signal generation details
- Trade execution results
- Error codes for failed operations

## Version History
- **v1.00**: Initial release with all technical indicators and divergence detection

## Support
For technical support and customization requests, refer to the MT5 community forums or contact the developer.