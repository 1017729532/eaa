//+------------------------------------------------------------------+
//|                                           TechnicalIndicatorsEA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "EA with RSI, KDJ, MACD, Bollinger Bands and Divergence Detection filters"

#include <Trade\Trade.mqh>
#include "Include\Divergence.mqh"

//--- Global variables
CTrade trade;
CDivergenceDetector divergence_detector;
int rsi_handle, macd_handle, stoch_handle, bb_handle;
bool first_trade_opened = false;

//--- Input parameters for RSI
input group "=== RSI Settings ==="
input int RSI_Period = 14;                    // RSI period
input ENUM_APPLIED_PRICE RSI_AppliedPrice = PRICE_CLOSE; // RSI applied price
input double RSI_Overbought = 70.0;           // RSI overbought level
input double RSI_Oversold = 30.0;             // RSI oversold level

//--- Input parameters for KDJ (Stochastic)
input group "=== KDJ (Stochastic) Settings ==="
input int KDJ_K_Period = 5;                   // %K period
input int KDJ_D_Period = 3;                   // %D period
input int KDJ_Slowing = 3;                    // Slowing
input ENUM_MA_METHOD KDJ_Method = MODE_SMA;   // Moving average method
input ENUM_STO_PRICE KDJ_PriceField = STO_LOWHIGH; // Price field
input double KDJ_Overbought = 80.0;           // KDJ overbought level
input double KDJ_Oversold = 20.0;             // KDJ oversold level

//--- Input parameters for MACD
input group "=== MACD Settings ==="
input int MACD_FastEMA = 12;                  // Fast EMA period
input int MACD_SlowEMA = 26;                  // Slow EMA period
input int MACD_SignalSMA = 9;                 // Signal SMA period
input ENUM_APPLIED_PRICE MACD_AppliedPrice = PRICE_CLOSE; // MACD applied price

//--- Input parameters for Bollinger Bands
input group "=== Bollinger Bands Settings ==="
input int BB_Period = 20;                     // BB period
input int BB_Shift = 0;                       // BB shift
input double BB_Deviation = 2.0;              // BB standard deviation
input ENUM_APPLIED_PRICE BB_AppliedPrice = PRICE_CLOSE; // BB applied price

//--- Input parameters for Divergence Detection
input group "=== Divergence Settings ==="
input int Divergence_Lookback = 10;           // Bars to look back for divergence
input double Divergence_MinStrength = 0.5;    // Minimum divergence strength

//--- Input parameters for Trading
input group "=== Trading Settings ==="
input double LotSize = 0.1;                   // Lot size
input int StopLoss = 100;                     // Stop loss in points
input int TakeProfit = 200;                   // Take profit in points
input int MagicNumber = 123456;               // Magic number
input string TradeComment = "TechIndicators_EA"; // Trade comment

//--- Input parameters for Filter Logic
input group "=== Filter Logic ==="
input bool Use_RSI_Filter = true;             // Use RSI filter
input bool Use_KDJ_Filter = true;             // Use KDJ filter
input bool Use_MACD_Filter = true;            // Use MACD filter
input bool Use_BB_Filter = true;              // Use Bollinger Bands filter
input bool Use_Divergence_Filter = true;      // Use divergence filter

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize indicators
   rsi_handle = iRSI(_Symbol, _Period, RSI_Period, RSI_AppliedPrice);
   if(rsi_handle == INVALID_HANDLE)
   {
      Print("Failed to create RSI indicator handle");
      return INIT_FAILED;
   }
   
   macd_handle = iMACD(_Symbol, _Period, MACD_FastEMA, MACD_SlowEMA, MACD_SignalSMA, MACD_AppliedPrice);
   if(macd_handle == INVALID_HANDLE)
   {
      Print("Failed to create MACD indicator handle");
      return INIT_FAILED;
   }
   
   stoch_handle = iStochastic(_Symbol, _Period, KDJ_K_Period, KDJ_D_Period, KDJ_Slowing, KDJ_Method, KDJ_PriceField);
   if(stoch_handle == INVALID_HANDLE)
   {
      Print("Failed to create Stochastic indicator handle");
      return INIT_FAILED;
   }
   
   bb_handle = iBands(_Symbol, _Period, BB_Period, BB_Shift, BB_Deviation, BB_AppliedPrice);
   if(bb_handle == INVALID_HANDLE)
   {
      Print("Failed to create Bollinger Bands indicator handle");
      return INIT_FAILED;
   }
   
   //--- Initialize divergence detector
   divergence_detector.SetLookbackBars(Divergence_Lookback);
   divergence_detector.SetMinStrength(Divergence_MinStrength);
   
   //--- Set trade parameters
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(10);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   Print("TechnicalIndicatorsEA initialized successfully");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(rsi_handle != INVALID_HANDLE)
      IndicatorRelease(rsi_handle);
   if(macd_handle != INVALID_HANDLE)
      IndicatorRelease(macd_handle);
   if(stoch_handle != INVALID_HANDLE)
      IndicatorRelease(stoch_handle);
   if(bb_handle != INVALID_HANDLE)
      IndicatorRelease(bb_handle);
   
   Print("TechnicalIndicatorsEA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if first trade already opened
   if(first_trade_opened)
      return;
      
   //--- Check if we have enough bars
   if(Bars(_Symbol, _Period) < 100)
      return;
   
   //--- Get current signal
   int signal = GetTradeSignal();
   
   //--- Open trade if signal is valid
   if(signal != 0)
   {
      if(signal > 0)
         OpenBuyTrade();
      else if(signal < 0)
         OpenSellTrade();
   }
}

//+------------------------------------------------------------------+
//| Get trade signal based on all filters                           |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   int buy_signals = 0;
   int sell_signals = 0;
   
   //--- RSI Filter
   if(Use_RSI_Filter)
   {
      int rsi_signal = GetRSISignal();
      if(rsi_signal > 0) buy_signals++;
      else if(rsi_signal < 0) sell_signals++;
   }
   
   //--- KDJ Filter
   if(Use_KDJ_Filter)
   {
      int kdj_signal = GetKDJSignal();
      if(kdj_signal > 0) buy_signals++;
      else if(kdj_signal < 0) sell_signals++;
   }
   
   //--- MACD Filter
   if(Use_MACD_Filter)
   {
      int macd_signal = GetMACDSignal();
      if(macd_signal > 0) buy_signals++;
      else if(macd_signal < 0) sell_signals++;
   }
   
   //--- Bollinger Bands Filter
   if(Use_BB_Filter)
   {
      int bb_signal = GetBBSignal();
      if(bb_signal > 0) buy_signals++;
      else if(bb_signal < 0) sell_signals++;
   }
   
   //--- Divergence Filter
   if(Use_Divergence_Filter)
   {
      int div_signal = GetDivergenceSignal();
      if(div_signal > 0) buy_signals++;
      else if(div_signal < 0) sell_signals++;
   }
   
   //--- Calculate required signals
   int total_filters = (Use_RSI_Filter ? 1 : 0) + (Use_KDJ_Filter ? 1 : 0) + 
                      (Use_MACD_Filter ? 1 : 0) + (Use_BB_Filter ? 1 : 0) + 
                      (Use_Divergence_Filter ? 1 : 0);
   
   //--- Return signal if majority of filters agree
   if(buy_signals >= total_filters * 0.6)
      return 1;
   else if(sell_signals >= total_filters * 0.6)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get RSI signal                                                  |
//+------------------------------------------------------------------+
int GetRSISignal()
{
   double rsi_values[3];
   if(CopyBuffer(rsi_handle, 0, 0, 3, rsi_values) < 3)
      return 0;
   
   double current_rsi = rsi_values[0];
   double prev_rsi = rsi_values[1];
   
   //--- Buy signal: RSI crosses above oversold level
   if(prev_rsi <= RSI_Oversold && current_rsi > RSI_Oversold)
      return 1;
   
   //--- Sell signal: RSI crosses below overbought level
   if(prev_rsi >= RSI_Overbought && current_rsi < RSI_Overbought)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get KDJ (Stochastic) signal                                     |
//+------------------------------------------------------------------+
int GetKDJSignal()
{
   double k_values[3], d_values[3];
   if(CopyBuffer(stoch_handle, 0, 0, 3, k_values) < 3 ||
      CopyBuffer(stoch_handle, 1, 0, 3, d_values) < 3)
      return 0;
   
   double current_k = k_values[0];
   double current_d = d_values[0];
   double prev_k = k_values[1];
   double prev_d = d_values[1];
   
   //--- Buy signal: K crosses above D in oversold area
   if(current_k < KDJ_Oversold && current_d < KDJ_Oversold &&
      prev_k <= prev_d && current_k > current_d)
      return 1;
   
   //--- Sell signal: K crosses below D in overbought area
   if(current_k > KDJ_Overbought && current_d > KDJ_Overbought &&
      prev_k >= prev_d && current_k < current_d)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get MACD signal                                                 |
//+------------------------------------------------------------------+
int GetMACDSignal()
{
   double macd_main[3], macd_signal[3];
   if(CopyBuffer(macd_handle, 0, 0, 3, macd_main) < 3 ||
      CopyBuffer(macd_handle, 1, 0, 3, macd_signal) < 3)
      return 0;
   
   double current_main = macd_main[0];
   double current_signal = macd_signal[0];
   double prev_main = macd_main[1];
   double prev_signal = macd_signal[1];
   
   //--- Buy signal: MACD line crosses above signal line
   if(prev_main <= prev_signal && current_main > current_signal)
      return 1;
   
   //--- Sell signal: MACD line crosses below signal line
   if(prev_main >= prev_signal && current_main < current_signal)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get Bollinger Bands signal                                      |
//+------------------------------------------------------------------+
int GetBBSignal()
{
   double bb_upper[2], bb_lower[2], bb_middle[2];
   if(CopyBuffer(bb_handle, 1, 0, 2, bb_upper) < 2 ||
      CopyBuffer(bb_handle, 2, 0, 2, bb_lower) < 2 ||
      CopyBuffer(bb_handle, 0, 0, 2, bb_middle) < 2)
      return 0;
   
   double current_price = iClose(_Symbol, _Period, 0);
   double prev_price = iClose(_Symbol, _Period, 1);
   
   //--- Buy signal: Price bounces from lower band
   if(prev_price <= bb_lower[1] && current_price > bb_lower[0])
      return 1;
   
   //--- Sell signal: Price bounces from upper band
   if(prev_price >= bb_upper[1] && current_price < bb_upper[0])
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Get divergence signal                                           |
//+------------------------------------------------------------------+
int GetDivergenceSignal()
{
   //--- Use advanced divergence detection
   int rsi_div = divergence_detector.DetectRSIDivergence(rsi_handle);
   int macd_div = divergence_detector.DetectMACDDivergence(macd_handle);
   int stoch_div = divergence_detector.DetectStochasticDivergence(stoch_handle);
   
   //--- Count signals
   int bullish_signals = 0;
   int bearish_signals = 0;
   
   if(rsi_div > 0) bullish_signals++;
   else if(rsi_div < 0) bearish_signals++;
   
   if(macd_div > 0) bullish_signals++;
   else if(macd_div < 0) bearish_signals++;
   
   if(stoch_div > 0) bullish_signals++;
   else if(stoch_div < 0) bearish_signals++;
   
   //--- Return signal if majority agrees
   if(bullish_signals >= 2)
      return 1;
   else if(bearish_signals >= 2)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Open buy trade                                                  |
//+------------------------------------------------------------------+
void OpenBuyTrade()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = ask - StopLoss * _Point;
   double tp = ask + TakeProfit * _Point;
   
   if(trade.Buy(LotSize, _Symbol, ask, sl, tp, TradeComment))
   {
      first_trade_opened = true;
      Print("Buy trade opened at ", ask, " SL: ", sl, " TP: ", tp);
   }
   else
   {
      Print("Failed to open buy trade. Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Open sell trade                                                 |
//+------------------------------------------------------------------+
void OpenSellTrade()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = bid + StopLoss * _Point;
   double tp = bid - TakeProfit * _Point;
   
   if(trade.Sell(LotSize, _Symbol, bid, sl, tp, TradeComment))
   {
      first_trade_opened = true;
      Print("Sell trade opened at ", bid, " SL: ", sl, " TP: ", tp);
   }
   else
   {
      Print("Failed to open sell trade. Error: ", GetLastError());
   }
}