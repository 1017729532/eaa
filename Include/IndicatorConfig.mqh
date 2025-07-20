//+------------------------------------------------------------------+
//|                                               IndicatorConfig.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Indicator configuration structure                                |
//+------------------------------------------------------------------+
struct SIndicatorConfig
{
   //--- RSI Configuration
   struct
   {
      int               period;
      ENUM_APPLIED_PRICE applied_price;
      double            overbought;
      double            oversold;
      bool              enabled;
   } rsi;
   
   //--- KDJ (Stochastic) Configuration
   struct
   {
      int               k_period;
      int               d_period;
      int               slowing;
      ENUM_MA_METHOD    method;
      ENUM_STO_PRICE    price_field;
      double            overbought;
      double            oversold;
      bool              enabled;
   } kdj;
   
   //--- MACD Configuration
   struct
   {
      int               fast_ema;
      int               slow_ema;
      int               signal_sma;
      ENUM_APPLIED_PRICE applied_price;
      bool              enabled;
   } macd;
   
   //--- Bollinger Bands Configuration
   struct
   {
      int               period;
      int               shift;
      double            deviation;
      ENUM_APPLIED_PRICE applied_price;
      bool              enabled;
   } bb;
   
   //--- Divergence Configuration
   struct
   {
      int               lookback;
      double            min_strength;
      bool              enabled;
   } divergence;
   
   //--- Trading Configuration
   struct
   {
      double            lot_size;
      int               stop_loss;
      int               take_profit;
      int               magic_number;
      string            comment;
   } trading;
};

//+------------------------------------------------------------------+
//| Default configuration values                                    |
//+------------------------------------------------------------------+
void InitDefaultConfig(SIndicatorConfig &config)
{
   //--- RSI defaults
   config.rsi.period = 14;
   config.rsi.applied_price = PRICE_CLOSE;
   config.rsi.overbought = 70.0;
   config.rsi.oversold = 30.0;
   config.rsi.enabled = true;
   
   //--- KDJ defaults
   config.kdj.k_period = 5;
   config.kdj.d_period = 3;
   config.kdj.slowing = 3;
   config.kdj.method = MODE_SMA;
   config.kdj.price_field = STO_LOWHIGH;
   config.kdj.overbought = 80.0;
   config.kdj.oversold = 20.0;
   config.kdj.enabled = true;
   
   //--- MACD defaults
   config.macd.fast_ema = 12;
   config.macd.slow_ema = 26;
   config.macd.signal_sma = 9;
   config.macd.applied_price = PRICE_CLOSE;
   config.macd.enabled = true;
   
   //--- Bollinger Bands defaults
   config.bb.period = 20;
   config.bb.shift = 0;
   config.bb.deviation = 2.0;
   config.bb.applied_price = PRICE_CLOSE;
   config.bb.enabled = true;
   
   //--- Divergence defaults
   config.divergence.lookback = 10;
   config.divergence.min_strength = 0.5;
   config.divergence.enabled = true;
   
   //--- Trading defaults
   config.trading.lot_size = 0.1;
   config.trading.stop_loss = 100;
   config.trading.take_profit = 200;
   config.trading.magic_number = 123456;
   config.trading.comment = "TechIndicators_EA";
}

//+------------------------------------------------------------------+
//| Configuration validation                                         |
//+------------------------------------------------------------------+
bool ValidateConfig(const SIndicatorConfig &config)
{
   //--- Validate RSI
   if(config.rsi.enabled)
   {
      if(config.rsi.period <= 0 || config.rsi.period > 1000)
      {
         Print("Invalid RSI period: ", config.rsi.period);
         return false;
      }
      if(config.rsi.overbought <= config.rsi.oversold)
      {
         Print("RSI overbought level must be greater than oversold level");
         return false;
      }
   }
   
   //--- Validate KDJ
   if(config.kdj.enabled)
   {
      if(config.kdj.k_period <= 0 || config.kdj.d_period <= 0 || config.kdj.slowing <= 0)
      {
         Print("Invalid KDJ periods");
         return false;
      }
      if(config.kdj.overbought <= config.kdj.oversold)
      {
         Print("KDJ overbought level must be greater than oversold level");
         return false;
      }
   }
   
   //--- Validate MACD
   if(config.macd.enabled)
   {
      if(config.macd.fast_ema <= 0 || config.macd.slow_ema <= 0 || config.macd.signal_sma <= 0)
      {
         Print("Invalid MACD periods");
         return false;
      }
      if(config.macd.fast_ema >= config.macd.slow_ema)
      {
         Print("MACD fast EMA must be less than slow EMA");
         return false;
      }
   }
   
   //--- Validate Bollinger Bands
   if(config.bb.enabled)
   {
      if(config.bb.period <= 0 || config.bb.deviation <= 0)
      {
         Print("Invalid Bollinger Bands parameters");
         return false;
      }
   }
   
   //--- Validate Divergence
   if(config.divergence.enabled)
   {
      if(config.divergence.lookback <= 0 || config.divergence.min_strength < 0)
      {
         Print("Invalid divergence parameters");
         return false;
      }
   }
   
   //--- Validate Trading
   if(config.trading.lot_size <= 0)
   {
      Print("Invalid lot size: ", config.trading.lot_size);
      return false;
   }
   
   return true;
}