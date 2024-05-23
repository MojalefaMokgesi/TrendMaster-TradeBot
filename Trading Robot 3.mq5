#include <Trade\Trade.mqh>

// Input parameters
input int MagicNumber = 123456; 
input string SymbolName = "EURUSD"; 
input int FastMA = 20; // Fast moving average period
input int SlowMA = 50; // Slow moving average period
input double SupportLevel = 1.32000; // Support level
input double ResistanceLevel = 1.38000; // Resistance level
input double TakeProfit = 0.0050; // Take Profit in points (0.0050 = 50 pips)
input double RiskPercentage = 1.0; // Risk percentage per trade (1.0 = 1%)
input double FixedLotSize = 0.1; // Fixed Lot Size

// Trend direction enumeration
enum TrendDirection
{
    NoTrend,
    UpTrend,
    DownTrend
};

TrendDirection prevTrend = NoTrend;
CTrade trade;

// Calculate lot size based on risk percentage
double CalculateLotSize(double riskPercentage, double stopLoss)
{
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE); // Change to AccountInfoDouble for MQL5
    double lotSize = (accountBalance * riskPercentage) / (stopLoss * 10.0);
    return lotSize;
}

// Open a buy position with stop loss at support level and take profit
void Buy(double supportLevel, double stopLoss)
{
    double lotSize = CalculateLotSize(RiskPercentage, stopLoss);
    
    MqlTradeRequest request = {1};
    MqlTradeResult result = {10};

    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_BUY;
    request.symbol = Symbol();
    request.volume = lotSize;
    request.price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    request.sl = supportLevel;
    request.tp = request.price + TakeProfit * _Point;
    request.deviation = 0; // Allowable deviation from the requested price
    request.type_filling = ORDER_FILLING_FOK; // Order execution type
    request.magic = MagicNumber;

    if (OrderSend(request, result) != TRADE_RETCODE_DONE)
        Print("Buy order failed, error code: ", result.retcode);
    else
        Print("Buy order executed, ticket: ", result.deal);
}

// Open a sell position with stop loss at resistance level and take profit
void Sell(double resistanceLevel, double stopLoss)
{
    double lotSize = CalculateLotSize(RiskPercentage, stopLoss);
    
    MqlTradeRequest request = {1};
    MqlTradeResult result = {10};

    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_SELL;
    request.symbol = Symbol();
    request.volume = lotSize;
    request.price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    request.sl = resistanceLevel;
    request.tp = request.price - TakeProfit * _Point;
    request.deviation = 0; // Allowable deviation from the requested price
    request.type_filling = ORDER_FILLING_FOK; // Order execution type
    request.magic = MagicNumber;

    if (!OrderSend(request, result))
        Print("Sell order failed, error code: ", result.retcode);
    else
        Print("Sell order executed, ticket: ", result.deal);
}


// Close all existing buy trades
void CloseBuyTrades()
{
    int totalPositions = PositionsTotal();
    for (int i = 0; i < totalPositions; i++)
    {
        if (PositionSelect(i))
        {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
                trade.PositionClose(PositionGetInteger(POSITION_TICKET));
            }
        }
    }
}

// Close all existing sell trades
void CloseSellTrades()
{
    int totalPositions = PositionsTotal();
    for (int i = 0; i < totalPositions; i++)
    {
        if (PositionSelect(i))
        {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
                trade.PositionClose(PositionGetInteger(POSITION_TICKET));
            }
        }
    }
}

// Expert tick function
void OnTick()
{
    double fastMA = iMA(Symbol(), 0, FastMA, 0, MODE_SMA, PRICE_CLOSE);
    double slowMA = iMA(Symbol(), 0, SlowMA, 0, MODE_SMA, PRICE_CLOSE);

    // Check for trend direction
    TrendDirection currentTrend = NoTrend;
    if (fastMA > slowMA)
    {
        currentTrend = UpTrend;
    }
    else if (fastMA < slowMA)
    {
        currentTrend = DownTrend;
    }

    // Implement trade logic based on the trend direction
    if (currentTrend != prevTrend)
    {
        if (currentTrend == UpTrend)
        {
            // Close any existing sell trades
            CloseSellTrades();
            
            // Buy at support level
            Buy(SupportLevel, SymbolInfoDouble(Symbol(), SYMBOL_ASK) - SupportLevel);
        }
        else if (currentTrend == DownTrend)
        {
            // Close any existing buy trades
            CloseBuyTrades();
            
            // Sell at resistance level
            Sell(ResistanceLevel, ResistanceLevel - SymbolInfoDouble(Symbol(), SYMBOL_BID));
        }

        prevTrend = currentTrend;
    }
}

// Expert initialization function
void OnInit()
{
    
}

// Expert deinitialization function
void OnDeinit(const int reason)
{
    
}

// Other standard functions
void OnTrade()
{
   
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    
}
