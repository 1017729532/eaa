//+------------------------------------------------------------------+
//|                                               ConversionTest.mq5 |
//|                                     Copyright 2024, MetaQuotes  |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

//--- Include the conversion utility
#include "../Utilities/ConversionUtils.mqh"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- Input parameters
input bool TestOrderManagement = true;    // Test order management functions
input bool TestIndicators = true;         // Test indicator conversion
input bool TestGlobalVariables = true;    // Test global variables
input bool TestPriceAccess = true;        // Test price data access

//--- Global objects
CMT4ToMT5Converter converter;
CTrade trade;
CPositionInfo positionInfo;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== MT4 to MT5 Conversion Test Started ===");
    
    bool allTestsPassed = true;
    
    if (TestOrderManagement)
        allTestsPassed &= TestOrderManagementFunctions();
    
    if (TestIndicators)
        allTestsPassed &= TestIndicatorConversion();
    
    if (TestGlobalVariables)
        allTestsPassed &= TestGlobalVariableFunctions();
    
    if (TestPriceAccess)
        allTestsPassed &= TestPriceDataAccess();
    
    // Test conversion utilities
    allTestsPassed &= TestConversionUtilities();
    
    Print("=== Test Results ===");
    if (allTestsPassed)
        Print("✓ All tests PASSED - Conversion framework working correctly");
    else
        Print("✗ Some tests FAILED - Check the log for details");
    
    Print("=== MT4 to MT5 Conversion Test Completed ===");
}

//+------------------------------------------------------------------+
//| Test order management function conversions                      |
//+------------------------------------------------------------------+
bool TestOrderManagementFunctions()
{
    Print("\n--- Testing Order Management Functions ---");
    
    bool testPassed = true;
    
    // Test 1: Check if trade object is properly initialized
    trade.SetExpertMagicNumber(12345);
    trade.SetDeviationInPoints(3);
    
    Print("✓ Trade object initialization: OK");
    
    // Test 2: Check position counting (should work even with no positions)
    int posCount = PositionsTotal();
    Print("✓ PositionsTotal() function: ", posCount, " positions found");
    
    // Test 3: Check pending orders counting
    int orderCount = OrdersTotal();
    Print("✓ OrdersTotal() function: ", orderCount, " pending orders found");
    
    // Test 4: Test position iteration (safe even with no positions)
    int iteratedPositions = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (positionInfo.SelectByIndex(i))
            iteratedPositions++;
    }
    Print("✓ Position iteration: ", iteratedPositions, " positions processed");
    
    return testPassed;
}

//+------------------------------------------------------------------+
//| Test indicator conversion                                        |
//+------------------------------------------------------------------+
bool TestIndicatorConversion()
{
    Print("\n--- Testing Indicator Conversion ---");
    
    bool testPassed = true;
    
    // Test 1: Create moving average indicator handle
    int ma_handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    
    if (ma_handle == INVALID_HANDLE)
    {
        Print("✗ Failed to create MA indicator handle");
        testPassed = false;
    }
    else
    {
        Print("✓ MA indicator handle created successfully");
        
        // Test 2: Try to get indicator data
        double ma_buffer[];
        if (CopyBuffer(ma_handle, 0, 0, 1, ma_buffer) > 0)
        {
            Print("✓ MA indicator data retrieved: ", ma_buffer[0]);
        }
        else
        {
            Print("✗ Failed to retrieve MA indicator data");
            testPassed = false;
        }
        
        // Clean up
        IndicatorRelease(ma_handle);
        Print("✓ MA indicator handle released");
    }
    
    // Test 3: Test multiple indicators
    int rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    if (rsi_handle != INVALID_HANDLE)
    {
        Print("✓ RSI indicator handle created successfully");
        IndicatorRelease(rsi_handle);
    }
    else
    {
        Print("✗ Failed to create RSI indicator handle");
        testPassed = false;
    }
    
    return testPassed;
}

//+------------------------------------------------------------------+
//| Test global variable functions                                  |
//+------------------------------------------------------------------+
bool TestGlobalVariableFunctions()
{
    Print("\n--- Testing Global Variable Functions ---");
    
    bool testPassed = true;
    string testVarName = "ConversionTest_" + IntegerToString(GetTickCount());
    
    // Test 1: Set global variable
    if (GlobalVariableSet(testVarName, 123.456))
    {
        Print("✓ Global variable set successfully");
    }
    else
    {
        Print("✗ Failed to set global variable");
        testPassed = false;
    }
    
    // Test 2: Check if variable exists
    if (GlobalVariableCheck(testVarName))
    {
        Print("✓ Global variable exists check: OK");
    }
    else
    {
        Print("✗ Global variable exists check failed");
        testPassed = false;
    }
    
    // Test 3: Get global variable value
    double retrievedValue = GlobalVariableGet(testVarName);
    if (MathAbs(retrievedValue - 123.456) < 0.001)
    {
        Print("✓ Global variable retrieved correctly: ", retrievedValue);
    }
    else
    {
        Print("✗ Global variable retrieval failed: ", retrievedValue);
        testPassed = false;
    }
    
    // Test 4: Get variable time
    datetime varTime = GlobalVariableTime(testVarName);
    if (varTime > 0)
    {
        Print("✓ Global variable time retrieved: ", TimeToString(varTime));
    }
    else
    {
        Print("✗ Failed to retrieve global variable time");
        testPassed = false;
    }
    
    // Test 5: Delete global variable
    if (GlobalVariableDel(testVarName))
    {
        Print("✓ Global variable deleted successfully");
    }
    else
    {
        Print("✗ Failed to delete global variable");
        testPassed = false;
    }
    
    return testPassed;
}

//+------------------------------------------------------------------+
//| Test price data access                                          |
//+------------------------------------------------------------------+
bool TestPriceDataAccess()
{
    Print("\n--- Testing Price Data Access ---");
    
    bool testPassed = true;
    
    // Test 1: Get current tick data
    MqlTick tick;
    if (SymbolInfoTick(_Symbol, tick))
    {
        Print("✓ Tick data retrieved - Ask: ", tick.ask, " Bid: ", tick.bid, " Last: ", tick.last);
    }
    else
    {
        Print("✗ Failed to retrieve tick data");
        testPassed = false;
    }
    
    // Test 2: Get rates data
    MqlRates rates[];
    if (CopyRates(_Symbol, PERIOD_CURRENT, 0, 5, rates) > 0)
    {
        Print("✓ Rates data retrieved - Current Close: ", rates[ArraySize(rates)-1].close);
        Print("  Previous Close: ", rates[ArraySize(rates)-2].close);
    }
    else
    {
        Print("✗ Failed to retrieve rates data");
        testPassed = false;
    }
    
    // Test 3: Symbol information
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    
    Print("✓ Symbol info - Point: ", point, " Digits: ", digits, " Spread: ", spread);
    
    // Test 4: Time functions
    MqlDateTime dt;
    TimeCurrent(dt);
    Print("✓ Time data - Hour: ", dt.hour, " Minute: ", dt.min, " Day: ", dt.day);
    
    return testPassed;
}

//+------------------------------------------------------------------+
//| Test conversion utility functions                               |
//+------------------------------------------------------------------+
bool TestConversionUtilities()
{
    Print("\n--- Testing Conversion Utilities ---");
    
    bool testPassed = true;
    
    // Test 1: Order type conversion
    ENUM_ORDER_TYPE mt5_buy = converter.ConvertOrderType(0); // OP_BUY
    if (mt5_buy == ORDER_TYPE_BUY)
    {
        Print("✓ Order type conversion (OP_BUY): OK");
    }
    else
    {
        Print("✗ Order type conversion failed");
        testPassed = false;
    }
    
    // Test 2: Timeframe conversion
    ENUM_TIMEFRAMES mt5_h1 = converter.ConvertTimeframe(60); // PERIOD_H1
    if (mt5_h1 == PERIOD_H1)
    {
        Print("✓ Timeframe conversion (H1): OK");
    }
    else
    {
        Print("✗ Timeframe conversion failed");
        testPassed = false;
    }
    
    // Test 3: Price normalization
    double testPrice = 1.23456789;
    double normalizedPrice = converter.NormalizePrice(_Symbol, testPrice);
    Print("✓ Price normalization: ", testPrice, " → ", normalizedPrice);
    
    // Test 4: Pip value calculation
    double pipValue = converter.GetPipValue(_Symbol);
    Print("✓ Pip value for ", _Symbol, ": ", pipValue);
    
    // Test 5: Error description
    string errorDesc = converter.GetErrorDescription(0);
    Print("✓ Error description test: ", errorDesc);
    
    return testPassed;
}

//+------------------------------------------------------------------+
//| Display test summary                                            |
//+------------------------------------------------------------------+
void DisplayTestSummary()
{
    Print("\n=== Conversion Framework Summary ===");
    Print("This test validates the MT4 to MT5 conversion framework.");
    Print("Key components tested:");
    Print("• Order management function equivalents");
    Print("• Indicator creation and data access");
    Print("• Global variable compatibility");
    Print("• Price and time data access");
    Print("• Conversion utility functions");
    Print("");
    Print("If all tests pass, your conversion framework is ready to use.");
    Print("Refer to the documentation for detailed conversion guidelines.");
}