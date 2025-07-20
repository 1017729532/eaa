# MT4 to MT5 EA Conversion Framework

A comprehensive framework for converting MetaTrader 4 (MT4) Expert Advisor code to MetaTrader 5 (MT5) while preserving all original functionality.

## Overview

This project provides a complete solution for migrating MT4 Expert Advisors to MT5, addressing the key differences in:
- Order management systems
- Trading functions and syntax
- Indicator access patterns
- Price and time data handling
- Global variable management
- Custom trading strategies

## Project Structure

```
├── MT4_Examples/           # Original MT4 EA examples
│   └── ComplexEA_MT4.mq4  # Complete MT4 EA with advanced features
├── MT5_Converted/          # Converted MT5 versions
│   └── ComplexEA_MT5.mq5  # MT5 equivalent with full functionality
├── Utilities/              # Conversion helper utilities
│   └── ConversionUtils.mqh # MT4-to-MT5 conversion utility class
├── Documentation/          # Comprehensive guides and references
│   ├── ConversionGuide.md     # Complete conversion guide
│   ├── SideBySideComparison.mqh # Code comparison examples
│   └── ConversionChecklist.md   # Step-by-step checklist
├── Tests/                  # Validation and testing
│   └── ConversionTest.mq5 # Framework validation script
└── README.md              # This file
```

## Key Features

### ✅ Complete Functionality Preservation
- Order management (market and pending orders)
- Stop loss and take profit handling
- Trailing stops and position management
- Global variable operations
- Custom trading strategy logic

### ✅ Modern MT5 Architecture
- Object-oriented design using CTrade class
- Proper indicator handle management
- Efficient price data access
- Enhanced error handling

### ✅ Conversion Utilities
- Helper functions for common conversions
- MT4-compatible wrapper functions
- Order type and constant mapping
- Price normalization utilities

### ✅ Comprehensive Documentation
- Step-by-step conversion guide
- Side-by-side code comparisons
- Detailed checklist for conversions
- Best practices and common pitfalls

## Quick Start

### 1. Review the Examples
Start by examining the example files:
- `MT4_Examples/ComplexEA_MT4.mq4` - Original MT4 EA
- `MT5_Converted/ComplexEA_MT5.mq5` - Converted MT5 version

### 2. Use the Conversion Utilities
Include the utility class in your MT5 EA:
```mql5
#include "Utilities/ConversionUtils.mqh"
CMT4ToMT5Converter converter;
```

### 3. Follow the Conversion Guide
Use `Documentation/ConversionGuide.md` for detailed instructions.

### 4. Validate Your Conversion
Run `Tests/ConversionTest.mq5` to ensure the framework is working correctly.

## Key Conversion Patterns

### Order Management
**MT4:**
```mql4
int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, sl, tp, "Comment", magic);
```

**MT5:**
```mql5
CTrade trade;
bool result = trade.Buy(0.1, _Symbol, ask, sl, tp, "Comment");
```

### Position Iteration
**MT4:**
```mql4
for(int i = OrdersTotal() - 1; i >= 0; i--)
{
    if(OrderSelect(i, SELECT_BY_POS))
    {
        // Process order
    }
}
```

**MT5:**
```mql5
CPositionInfo positionInfo;
for(int i = PositionsTotal() - 1; i >= 0; i--)
{
    if(positionInfo.SelectByIndex(i))
    {
        // Process position
    }
}
```

### Indicator Access
**MT4:**
```mql4
double ma = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
```

**MT5:**
```mql5
int ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
double ma_buffer[];
CopyBuffer(ma_handle, 0, 0, 1, ma_buffer);
double ma = ma_buffer[0];
```

## Conversion Process

1. **Analysis** - Identify MT4-specific functions and patterns
2. **Setup** - Create MT5 file structure and includes
3. **Core Conversion** - Convert trading functions and logic
4. **Testing** - Validate functionality in Strategy Tester
5. **Optimization** - Enhance with MT5-specific features

## Files Description

### MT4_Examples/ComplexEA_MT4.mq4
Complete MT4 Expert Advisor demonstrating:
- Market and pending order management
- Stop loss and take profit handling
- Trailing stops
- Global variable usage
- Custom trading strategy
- Time-based trading controls

### MT5_Converted/ComplexEA_MT5.mq5
Fully converted MT5 version featuring:
- CTrade class implementation
- Proper indicator handle management
- MT5 event handlers (OnTrade, OnTimer)
- Enhanced error handling
- Modern MT5 architecture

### Utilities/ConversionUtils.mqh
Utility class providing:
- MT4-compatible wrapper functions
- Order type conversions
- Price normalization
- Error handling improvements
- Timeframe conversions

### Documentation/
- **ConversionGuide.md** - Comprehensive conversion guide
- **SideBySideComparison.mqh** - Code comparison examples
- **ConversionChecklist.md** - Step-by-step checklist

### Tests/ConversionTest.mq5
Validation script testing:
- Order management functions
- Indicator conversions
- Global variables
- Price data access
- Utility functions

## Requirements

- MetaTrader 5 platform
- Basic understanding of MQL4/MQL5
- Access to MT5 Strategy Tester for validation

## Usage Instructions

1. **Copy the framework** to your MT5 data folder
2. **Study the examples** to understand conversion patterns
3. **Use the checklist** to systematically convert your EA
4. **Test thoroughly** in Strategy Tester
5. **Validate results** against original MT4 EA

## Best Practices

- Always test converted EAs in demo environment first
- Compare Strategy Tester results between MT4 and MT5 versions
- Handle indicator resources properly (create in OnInit, release in OnDeinit)
- Use proper error handling for all trade operations
- Normalize prices according to symbol specifications

## Common Pitfalls

1. **Forgetting to release indicator handles** - Can cause memory leaks
2. **Not handling 5-digit broker differences** - Point value calculations
3. **Mixing positions and orders** - MT5 separates these concepts
4. **Improper error handling** - Use trade.ResultRetcode() instead of GetLastError()
5. **Direct price array access** - Use CopyRates() and CopyBuffer() in MT5

## Support and Contribution

This framework is designed to handle the most common MT4 to MT5 conversion scenarios. For complex custom indicators or advanced features, additional modifications may be required.

## License

This conversion framework is provided as-is for educational and practical use. Test thoroughly before using in live trading environments.

---

**Note:** Always validate converted EAs thoroughly in a demo environment before live trading. Results may vary between MT4 and MT5 due to platform differences.
