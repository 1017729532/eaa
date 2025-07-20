//+------------------------------------------------------------------+
//|                                                   Divergence.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Divergence detection class                                       |
//+------------------------------------------------------------------+
class CDivergenceDetector
{
private:
   int               m_lookback_bars;
   double            m_min_strength;
   
public:
                     CDivergenceDetector(int lookback = 10, double min_strength = 0.5);
                    ~CDivergenceDetector();
   
   //--- Main divergence detection methods
   int               DetectRSIDivergence(int rsi_handle);
   int               DetectMACDDivergence(int macd_handle);
   int               DetectStochasticDivergence(int stoch_handle);
   
   //--- Helper methods
   bool              IsBullishDivergence(const double &price_array[], const double &indicator_array[], int bars);
   bool              IsBearishDivergence(const double &price_array[], const double &indicator_array[], int bars);
   int               FindRecentPivot(const double &array[], bool find_high = true, int start_pos = 1, int count = 10);
   double            CalculateDivergenceStrength(double val1, double val2);
   
   //--- Setters
   void              SetLookbackBars(int bars) { m_lookback_bars = bars; }
   void              SetMinStrength(double strength) { m_min_strength = strength; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDivergenceDetector::CDivergenceDetector(int lookback = 10, double min_strength = 0.5)
{
   m_lookback_bars = lookback;
   m_min_strength = min_strength;
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CDivergenceDetector::~CDivergenceDetector()
{
}

//+------------------------------------------------------------------+
//| Detect RSI divergence                                           |
//+------------------------------------------------------------------+
int CDivergenceDetector::DetectRSIDivergence(int rsi_handle)
{
   if(rsi_handle == INVALID_HANDLE)
      return 0;
   
   double rsi_values[];
   double highs[], lows[];
   
   ArraySetAsSeries(rsi_values, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   int bars_needed = m_lookback_bars + 5;
   
   if(CopyBuffer(rsi_handle, 0, 0, bars_needed, rsi_values) < bars_needed ||
      CopyHigh(_Symbol, _Period, 0, bars_needed, highs) < bars_needed ||
      CopyLow(_Symbol, _Period, 0, bars_needed, lows) < bars_needed)
      return 0;
   
   //--- Check for bullish divergence
   if(IsBullishDivergence(lows, rsi_values, m_lookback_bars))
      return 1;
   
   //--- Check for bearish divergence  
   if(IsBearishDivergence(highs, rsi_values, m_lookback_bars))
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Detect MACD divergence                                          |
//+------------------------------------------------------------------+
int CDivergenceDetector::DetectMACDDivergence(int macd_handle)
{
   if(macd_handle == INVALID_HANDLE)
      return 0;
   
   double macd_values[];
   double highs[], lows[];
   
   ArraySetAsSeries(macd_values, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   int bars_needed = m_lookback_bars + 5;
   
   if(CopyBuffer(macd_handle, 0, 0, bars_needed, macd_values) < bars_needed ||
      CopyHigh(_Symbol, _Period, 0, bars_needed, highs) < bars_needed ||
      CopyLow(_Symbol, _Period, 0, bars_needed, lows) < bars_needed)
      return 0;
   
   //--- Check for bullish divergence
   if(IsBullishDivergence(lows, macd_values, m_lookback_bars))
      return 1;
   
   //--- Check for bearish divergence
   if(IsBearishDivergence(highs, macd_values, m_lookback_bars))
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Detect Stochastic divergence                                    |
//+------------------------------------------------------------------+
int CDivergenceDetector::DetectStochasticDivergence(int stoch_handle)
{
   if(stoch_handle == INVALID_HANDLE)
      return 0;
   
   double stoch_values[];
   double highs[], lows[];
   
   ArraySetAsSeries(stoch_values, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   int bars_needed = m_lookback_bars + 5;
   
   if(CopyBuffer(stoch_handle, 0, 0, bars_needed, stoch_values) < bars_needed ||
      CopyHigh(_Symbol, _Period, 0, bars_needed, highs) < bars_needed ||
      CopyLow(_Symbol, _Period, 0, bars_needed, lows) < bars_needed)
      return 0;
   
   //--- Check for bullish divergence
   if(IsBullishDivergence(lows, stoch_values, m_lookback_bars))
      return 1;
   
   //--- Check for bearish divergence
   if(IsBearishDivergence(highs, stoch_values, m_lookback_bars))
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Check for bullish divergence                                    |
//+------------------------------------------------------------------+
bool CDivergenceDetector::IsBullishDivergence(const double &price_array[], const double &indicator_array[], int bars)
{
   //--- Find recent low in price
   int recent_low_idx = FindRecentPivot(price_array, false, 1, bars);
   if(recent_low_idx <= 0)
      return false;
   
   //--- Find earlier low in price
   int earlier_low_idx = FindRecentPivot(price_array, false, recent_low_idx + 2, bars - recent_low_idx);
   if(earlier_low_idx <= recent_low_idx)
      return false;
   
   //--- Check if price made lower low
   if(price_array[0] >= price_array[recent_low_idx])
      return false;
   
   //--- Check if indicator made higher low
   if(indicator_array[0] <= indicator_array[recent_low_idx])
      return false;
   
   //--- Calculate divergence strength
   double price_change = (price_array[recent_low_idx] - price_array[0]) / price_array[0];
   double indicator_change = (indicator_array[0] - indicator_array[recent_low_idx]) / MathAbs(indicator_array[recent_low_idx]);
   
   return (indicator_change > m_min_strength && price_change > 0.001);
}

//+------------------------------------------------------------------+
//| Check for bearish divergence                                    |
//+------------------------------------------------------------------+
bool CDivergenceDetector::IsBearishDivergence(const double &price_array[], const double &indicator_array[], int bars)
{
   //--- Find recent high in price
   int recent_high_idx = FindRecentPivot(price_array, true, 1, bars);
   if(recent_high_idx <= 0)
      return false;
   
   //--- Find earlier high in price
   int earlier_high_idx = FindRecentPivot(price_array, true, recent_high_idx + 2, bars - recent_high_idx);
   if(earlier_high_idx <= recent_high_idx)
      return false;
   
   //--- Check if price made higher high
   if(price_array[0] <= price_array[recent_high_idx])
      return false;
   
   //--- Check if indicator made lower high
   if(indicator_array[0] >= indicator_array[recent_high_idx])
      return false;
   
   //--- Calculate divergence strength
   double price_change = (price_array[0] - price_array[recent_high_idx]) / price_array[recent_high_idx];
   double indicator_change = (indicator_array[recent_high_idx] - indicator_array[0]) / MathAbs(indicator_array[recent_high_idx]);
   
   return (indicator_change > m_min_strength && price_change > 0.001);
}

//+------------------------------------------------------------------+
//| Find recent pivot point                                         |
//+------------------------------------------------------------------+
int CDivergenceDetector::FindRecentPivot(const double &array[], bool find_high = true, int start_pos = 1, int count = 10)
{
   if(start_pos >= ArraySize(array) || count <= 0)
      return -1;
   
   int end_pos = MathMin(start_pos + count, ArraySize(array) - 1);
   int pivot_idx = start_pos;
   
   for(int i = start_pos + 1; i <= end_pos; i++)
   {
      if(find_high)
      {
         if(array[i] > array[pivot_idx])
            pivot_idx = i;
      }
      else
      {
         if(array[i] < array[pivot_idx])
            pivot_idx = i;
      }
   }
   
   return pivot_idx;
}

//+------------------------------------------------------------------+
//| Calculate divergence strength                                   |
//+------------------------------------------------------------------+
double CDivergenceDetector::CalculateDivergenceStrength(double val1, double val2)
{
   if(val2 == 0.0)
      return 0.0;
   
   return MathAbs((val1 - val2) / val2);
}