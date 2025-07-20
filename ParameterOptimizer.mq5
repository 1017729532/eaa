//+------------------------------------------------------------------+
//|                                           ParameterOptimizer.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Parameter optimization helper for Technical Indicators EA"
#property script_show_inputs

#include "Include\IndicatorConfig.mqh"

//--- Input parameters for optimization
input group "=== Optimization Settings ==="
input int OptimizationBars = 1000;              // Bars to analyze for optimization
input bool OptimizeRSI = true;                  // Optimize RSI parameters
input bool OptimizeKDJ = true;                  // Optimize KDJ parameters
input bool OptimizeMacd = true;                 // Optimize MACD parameters
input bool OptimizeBB = true;                   // Optimize Bollinger Bands parameters

input group "=== RSI Optimization Range ==="
input int RSI_PeriodMin = 10;                   // RSI period minimum
input int RSI_PeriodMax = 20;                   // RSI period maximum
input int RSI_PeriodStep = 2;                   // RSI period step

input group "=== KDJ Optimization Range ==="
input int KDJ_KMin = 3;                         // KDJ %K minimum
input int KDJ_KMax = 8;                         // KDJ %K maximum
input int KDJ_DMin = 2;                         // KDJ %D minimum
input int KDJ_DMax = 5;                         // KDJ %D maximum

input group "=== MACD Optimization Range ==="
input int MACD_FastMin = 8;                     // MACD fast EMA minimum
input int MACD_FastMax = 16;                    // MACD fast EMA maximum
input int MACD_SlowMin = 20;                    // MACD slow EMA minimum
input int MACD_SlowMax = 32;                    // MACD slow EMA maximum

//--- Structure to hold optimization results
struct SOptimizationResult
{
   int rsi_period;
   int kdj_k;
   int kdj_d;
   int macd_fast;
   int macd_slow;
   int bb_period;
   double score;
   int signals_count;
};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Parameter Optimization Started ===");
   Print("Analyzing ", OptimizationBars, " bars for optimal parameters");
   
   //--- Check if we have enough data
   if(Bars(_Symbol, _Period) < OptimizationBars + 100)
   {
      Print("Error: Not enough historical data for optimization");
      return;
   }
   
   SOptimizationResult best_result = {0};
   best_result.score = -1.0;
   
   int total_combinations = 0;
   int tested_combinations = 0;
   
   //--- Calculate total combinations
   if(OptimizeRSI)
      total_combinations += (RSI_PeriodMax - RSI_PeriodMin) / RSI_PeriodStep + 1;
   
   Print("Starting optimization process...");
   
   //--- RSI optimization
   if(OptimizeRSI)
   {
      Print("Optimizing RSI parameters...");
      for(int rsi_period = RSI_PeriodMin; rsi_period <= RSI_PeriodMax; rsi_period += RSI_PeriodStep)
      {
         SOptimizationResult result = TestRSIParameters(rsi_period);
         tested_combinations++;
         
         if(result.score > best_result.score)
         {
            best_result = result;
            Print("New best RSI period: ", rsi_period, " Score: ", DoubleToString(result.score, 4));
         }
         
         if(tested_combinations % 5 == 0)
         {
            double progress = (double)tested_combinations / total_combinations * 100;
            Print("Progress: ", DoubleToString(progress, 1), "%");
         }
      }
   }
   
   //--- KDJ optimization
   if(OptimizeKDJ)
   {
      Print("Optimizing KDJ parameters...");
      SOptimizationResult kdj_result = OptimizeKDJParameters();
      if(kdj_result.score > 0)
      {
         Print("Best KDJ: K=", kdj_result.kdj_k, " D=", kdj_result.kdj_d, 
               " Score=", DoubleToString(kdj_result.score, 4));
      }
   }
   
   //--- MACD optimization
   if(OptimizeMacd)
   {
      Print("Optimizing MACD parameters...");
      SOptimizationResult macd_result = OptimizeMACDParameters();
      if(macd_result.score > 0)
      {
         Print("Best MACD: Fast=", macd_result.macd_fast, " Slow=", macd_result.macd_slow,
               " Score=", DoubleToString(macd_result.score, 4));
      }
   }
   
   //--- BB optimization
   if(OptimizeBB)
   {
      Print("Optimizing Bollinger Bands parameters...");
      SOptimizationResult bb_result = OptimizeBBParameters();
      if(bb_result.score > 0)
      {
         Print("Best BB period: ", bb_result.bb_period, 
               " Score=", DoubleToString(bb_result.score, 4));
      }
   }
   
   //--- Print final recommendations
   PrintOptimizationResults(best_result);
   
   Print("=== Parameter Optimization Completed ===");
}

//+------------------------------------------------------------------+
//| Test RSI parameters                                             |
//+------------------------------------------------------------------+
SOptimizationResult TestRSIParameters(int period)
{
   SOptimizationResult result = {0};
   result.rsi_period = period;
   
   //--- Create RSI indicator
   int rsi_handle = iRSI(_Symbol, _Period, period, PRICE_CLOSE);
   if(rsi_handle == INVALID_HANDLE)
   {
      return result;
   }
   
   //--- Wait for data
   Sleep(100);
   
   double rsi_values[];
   ArraySetAsSeries(rsi_values, true);
   
   if(CopyBuffer(rsi_handle, 0, 0, OptimizationBars, rsi_values) < OptimizationBars)
   {
      IndicatorRelease(rsi_handle);
      return result;
   }
   
   //--- Analyze signals
   int signals = 0;
   int profitable_signals = 0;
   
   for(int i = 1; i < OptimizationBars - 10; i++)
   {
      //--- Check for buy signal (RSI crosses above 30)
      if(rsi_values[i+1] <= 30.0 && rsi_values[i] > 30.0)
      {
         signals++;
         //--- Check if price moves up in next 5 bars
         double entry_price = iClose(_Symbol, _Period, i);
         double exit_price = iClose(_Symbol, _Period, i-5);
         if(exit_price > entry_price)
            profitable_signals++;
      }
      
      //--- Check for sell signal (RSI crosses below 70)
      if(rsi_values[i+1] >= 70.0 && rsi_values[i] < 70.0)
      {
         signals++;
         //--- Check if price moves down in next 5 bars
         double entry_price = iClose(_Symbol, _Period, i);
         double exit_price = iClose(_Symbol, _Period, i-5);
         if(exit_price < entry_price)
            profitable_signals++;
      }
   }
   
   //--- Calculate score
   if(signals > 0)
   {
      result.score = (double)profitable_signals / signals;
      result.signals_count = signals;
   }
   
   IndicatorRelease(rsi_handle);
   return result;
}

//+------------------------------------------------------------------+
//| Optimize KDJ parameters                                         |
//+------------------------------------------------------------------+
SOptimizationResult OptimizeKDJParameters()
{
   SOptimizationResult best_result = {0};
   best_result.score = -1.0;
   
   for(int k = KDJ_KMin; k <= KDJ_KMax; k++)
   {
      for(int d = KDJ_DMin; d <= KDJ_DMax; d++)
      {
         SOptimizationResult result = TestKDJParameters(k, d);
         if(result.score > best_result.score)
         {
            best_result = result;
         }
      }
   }
   
   return best_result;
}

//+------------------------------------------------------------------+
//| Test KDJ parameters                                             |
//+------------------------------------------------------------------+
SOptimizationResult TestKDJParameters(int k_period, int d_period)
{
   SOptimizationResult result = {0};
   result.kdj_k = k_period;
   result.kdj_d = d_period;
   
   int stoch_handle = iStochastic(_Symbol, _Period, k_period, d_period, 3, MODE_SMA, STO_LOWHIGH);
   if(stoch_handle == INVALID_HANDLE)
      return result;
   
   Sleep(100);
   
   double k_values[], d_values[];
   ArraySetAsSeries(k_values, true);
   ArraySetAsSeries(d_values, true);
   
   if(CopyBuffer(stoch_handle, 0, 0, OptimizationBars, k_values) < OptimizationBars ||
      CopyBuffer(stoch_handle, 1, 0, OptimizationBars, d_values) < OptimizationBars)
   {
      IndicatorRelease(stoch_handle);
      return result;
   }
   
   //--- Count crossover signals
   int signals = 0;
   for(int i = 1; i < OptimizationBars - 1; i++)
   {
      if((k_values[i+1] <= d_values[i+1] && k_values[i] > d_values[i]) ||
         (k_values[i+1] >= d_values[i+1] && k_values[i] < d_values[i]))
      {
         signals++;
      }
   }
   
   result.signals_count = signals;
   result.score = signals > 0 ? (double)signals / OptimizationBars * 100 : 0;
   
   IndicatorRelease(stoch_handle);
   return result;
}

//+------------------------------------------------------------------+
//| Optimize MACD parameters                                        |
//+------------------------------------------------------------------+
SOptimizationResult OptimizeMACDParameters()
{
   SOptimizationResult best_result = {0};
   best_result.score = -1.0;
   
   for(int fast = MACD_FastMin; fast <= MACD_FastMax; fast += 2)
   {
      for(int slow = MACD_SlowMin; slow <= MACD_SlowMax; slow += 2)
      {
         if(fast >= slow) continue;
         
         SOptimizationResult result = TestMACDParameters(fast, slow);
         if(result.score > best_result.score)
         {
            best_result = result;
         }
      }
   }
   
   return best_result;
}

//+------------------------------------------------------------------+
//| Test MACD parameters                                            |
//+------------------------------------------------------------------+
SOptimizationResult TestMACDParameters(int fast_ema, int slow_ema)
{
   SOptimizationResult result = {0};
   result.macd_fast = fast_ema;
   result.macd_slow = slow_ema;
   
   int macd_handle = iMACD(_Symbol, _Period, fast_ema, slow_ema, 9, PRICE_CLOSE);
   if(macd_handle == INVALID_HANDLE)
      return result;
   
   Sleep(100);
   
   double main_values[], signal_values[];
   ArraySetAsSeries(main_values, true);
   ArraySetAsSeries(signal_values, true);
   
   if(CopyBuffer(macd_handle, 0, 0, OptimizationBars, main_values) < OptimizationBars ||
      CopyBuffer(macd_handle, 1, 0, OptimizationBars, signal_values) < OptimizationBars)
   {
      IndicatorRelease(macd_handle);
      return result;
   }
   
   //--- Count crossover signals
   int signals = 0;
   for(int i = 1; i < OptimizationBars - 1; i++)
   {
      if((main_values[i+1] <= signal_values[i+1] && main_values[i] > signal_values[i]) ||
         (main_values[i+1] >= signal_values[i+1] && main_values[i] < signal_values[i]))
      {
         signals++;
      }
   }
   
   result.signals_count = signals;
   result.score = signals > 0 ? (double)signals / OptimizationBars * 100 : 0;
   
   IndicatorRelease(macd_handle);
   return result;
}

//+------------------------------------------------------------------+
//| Optimize Bollinger Bands parameters                             |
//+------------------------------------------------------------------+
SOptimizationResult OptimizeBBParameters()
{
   SOptimizationResult best_result = {0};
   best_result.score = -1.0;
   
   for(int period = 15; period <= 25; period += 2)
   {
      SOptimizationResult result = TestBBParameters(period);
      if(result.score > best_result.score)
      {
         best_result = result;
      }
   }
   
   return best_result;
}

//+------------------------------------------------------------------+
//| Test Bollinger Bands parameters                                 |
//+------------------------------------------------------------------+
SOptimizationResult TestBBParameters(int period)
{
   SOptimizationResult result = {0};
   result.bb_period = period;
   
   int bb_handle = iBands(_Symbol, _Period, period, 0, 2.0, PRICE_CLOSE);
   if(bb_handle == INVALID_HANDLE)
      return result;
   
   Sleep(100);
   
   double upper[], lower[];
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   
   if(CopyBuffer(bb_handle, 1, 0, OptimizationBars, upper) < OptimizationBars ||
      CopyBuffer(bb_handle, 2, 0, OptimizationBars, lower) < OptimizationBars)
   {
      IndicatorRelease(bb_handle);
      return result;
   }
   
   //--- Count band touch signals
   int signals = 0;
   for(int i = 0; i < OptimizationBars - 1; i++)
   {
      double close_price = iClose(_Symbol, _Period, i);
      if(close_price <= lower[i] || close_price >= upper[i])
      {
         signals++;
      }
   }
   
   result.signals_count = signals;
   result.score = signals > 0 ? (double)signals / OptimizationBars * 100 : 0;
   
   IndicatorRelease(bb_handle);
   return result;
}

//+------------------------------------------------------------------+
//| Print optimization results                                      |
//+------------------------------------------------------------------+
void PrintOptimizationResults(const SOptimizationResult &result)
{
   Print("=== OPTIMIZATION RESULTS ===");
   
   if(result.score > 0)
   {
      Print("Best overall score: ", DoubleToString(result.score, 4));
      if(result.rsi_period > 0)
         Print("Recommended RSI period: ", result.rsi_period);
      if(result.kdj_k > 0)
         Print("Recommended KDJ K period: ", result.kdj_k);
      if(result.kdj_d > 0)
         Print("Recommended KDJ D period: ", result.kdj_d);
      if(result.macd_fast > 0)
         Print("Recommended MACD Fast EMA: ", result.macd_fast);
      if(result.macd_slow > 0)
         Print("Recommended MACD Slow EMA: ", result.macd_slow);
      if(result.bb_period > 0)
         Print("Recommended BB period: ", result.bb_period);
      
      Print("Total signals generated: ", result.signals_count);
   }
   else
   {
      Print("No optimal parameters found. Consider:");
      Print("- Using different optimization ranges");
      Print("- Checking market conditions");
      Print("- Increasing optimization period");
   }
   
   Print("==============================");
}