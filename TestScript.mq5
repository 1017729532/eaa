//+------------------------------------------------------------------+
//|                                                    TestScript.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include "Include\Divergence.mqh"
#include "Include\IndicatorConfig.mqh"

//--- Input parameters
input int TestRSIPeriod = 14;
input int TestMACDFast = 12;
input int TestMACDSlow = 26;
input int TestDivergenceLookback = 10;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Technical Indicators EA Test Script ===");
   
   //--- Test configuration structure
   TestConfiguration();
   
   //--- Test divergence detector
   TestDivergenceDetector();
   
   //--- Test indicator handles creation
   TestIndicatorHandles();
   
   Print("=== Test Script Completed ===");
}

//+------------------------------------------------------------------+
//| Test configuration structure                                    |
//+------------------------------------------------------------------+
void TestConfiguration()
{
   Print("Testing configuration structure...");
   
   SIndicatorConfig config;
   InitDefaultConfig(config);
   
   //--- Test default values
   if(config.rsi.period == 14 && config.rsi.overbought == 70.0)
   {
      Print("✓ RSI default configuration OK");
   }
   else
   {
      Print("✗ RSI default configuration FAILED");
   }
   
   if(config.macd.fast_ema == 12 && config.macd.slow_ema == 26)
   {
      Print("✓ MACD default configuration OK");
   }
   else
   {
      Print("✗ MACD default configuration FAILED");
   }
   
   //--- Test validation
   if(ValidateConfig(config))
   {
      Print("✓ Configuration validation OK");
   }
   else
   {
      Print("✗ Configuration validation FAILED");
   }
   
   //--- Test invalid configuration
   config.rsi.period = -1;
   if(!ValidateConfig(config))
   {
      Print("✓ Invalid configuration detection OK");
   }
   else
   {
      Print("✗ Invalid configuration detection FAILED");
   }
}

//+------------------------------------------------------------------+
//| Test divergence detector                                        |
//+------------------------------------------------------------------+
void TestDivergenceDetector()
{
   Print("Testing divergence detector...");
   
   CDivergenceDetector detector(TestDivergenceLookback, 0.5);
   
   //--- Test with RSI handle
   int rsi_handle = iRSI(_Symbol, _Period, TestRSIPeriod, PRICE_CLOSE);
   if(rsi_handle != INVALID_HANDLE)
   {
      Print("✓ RSI handle created successfully");
      
      //--- Wait for data
      Sleep(1000);
      
      //--- Test divergence detection (may return 0 if no divergence found)
      int div_signal = detector.DetectRSIDivergence(rsi_handle);
      Print("RSI divergence signal: ", div_signal);
      Print("✓ RSI divergence detection executed");
      
      IndicatorRelease(rsi_handle);
   }
   else
   {
      Print("✗ Failed to create RSI handle");
   }
   
   //--- Test MACD divergence
   int macd_handle = iMACD(_Symbol, _Period, TestMACDFast, TestMACDSlow, 9, PRICE_CLOSE);
   if(macd_handle != INVALID_HANDLE)
   {
      Print("✓ MACD handle created successfully");
      
      //--- Wait for data
      Sleep(1000);
      
      int div_signal = detector.DetectMACDDivergence(macd_handle);
      Print("MACD divergence signal: ", div_signal);
      Print("✓ MACD divergence detection executed");
      
      IndicatorRelease(macd_handle);
   }
   else
   {
      Print("✗ Failed to create MACD handle");
   }
}

//+------------------------------------------------------------------+
//| Test indicator handles creation                                 |
//+------------------------------------------------------------------+
void TestIndicatorHandles()
{
   Print("Testing indicator handles creation...");
   
   //--- Test RSI
   int rsi_h = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   if(rsi_h != INVALID_HANDLE)
   {
      Print("✓ RSI handle creation OK");
      IndicatorRelease(rsi_h);
   }
   else
   {
      Print("✗ RSI handle creation FAILED");
   }
   
   //--- Test MACD
   int macd_h = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   if(macd_h != INVALID_HANDLE)
   {
      Print("✓ MACD handle creation OK");
      IndicatorRelease(macd_h);
   }
   else
   {
      Print("✗ MACD handle creation FAILED");
   }
   
   //--- Test Stochastic
   int stoch_h = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   if(stoch_h != INVALID_HANDLE)
   {
      Print("✓ Stochastic handle creation OK");
      IndicatorRelease(stoch_h);
   }
   else
   {
      Print("✗ Stochastic handle creation FAILED");
   }
   
   //--- Test Bollinger Bands
   int bb_h = iBands(_Symbol, _Period, 20, 0, 2.0, PRICE_CLOSE);
   if(bb_h != INVALID_HANDLE)
   {
      Print("✓ Bollinger Bands handle creation OK");
      IndicatorRelease(bb_h);
   }
   else
   {
      Print("✗ Bollinger Bands handle creation FAILED");
   }
   
   //--- Test data availability
   if(Bars(_Symbol, _Period) > 50)
   {
      Print("✓ Sufficient historical data available (", Bars(_Symbol, _Period), " bars)");
   }
   else
   {
      Print("⚠ Limited historical data (", Bars(_Symbol, _Period), " bars)");
   }
}