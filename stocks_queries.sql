CREATE DATABASE stock_analytics;
USE stock_analytics;

SHOW TABLES;

-- latest_price_of_everystock

CREATE VIEW vw_latest_close AS
SELECT Ticker, Close
FROM stock_prices_ymd
WHERE Date = (
    SELECT MAX(Date)
    FROM stock_prices_ymd
);

-- no of bullish days

CREATE VIEW vw_bullish_days AS
SELECT ticker,
    COUNT(*) AS bullish_days
FROM stock_prices_ymd
WHERE close > open
GROUP BY ticker
ORDER BY bullish_days DESC;

-- no of bearish days

CREATE VIEW vw_bearish_days AS
SELECT ticker,
    COUNT(*) AS bearish_days
FROM stock_prices_ymd
WHERE close < open
GROUP BY ticker
ORDER BY bearish_days DESC;

-- highest closing price of each stock

CREATE VIEW vw_highest_closing_price AS
SELECT ticker,
    MAX(close) AS highest_closing_price
FROM stock_prices_ymd
GROUP BY ticker
ORDER BY highest_closing_price DESC;

-- lowest closing price of each stock

CREATE VIEW vw_lowest_closing_price AS
SELECT ticker,
    MIN(close) AS lowest_closing_price
FROM stock_prices_ymd
GROUP BY ticker
ORDER BY lowest_closing_price DESC;

-- top 10 trading days by value '

CREATE VIEW vw_top10_traded_value_days AS
SELECT ticker, volume, date, close,
    ROUND(close * volume, 2) AS traded_value
FROM stock_prices_ymd
ORDER BY traded_value DESC
LIMIT 10;

-- volatility status of each stock
 
CREATE VIEW vw_volatility_range AS
SELECT ticker,
    ((MAX(close) - MIN(close)) / MAX(close)) * 100 AS volatile
FROM stock_prices_ymd
GROUP BY ticker
ORDER BY volatile DESC;

CREATE VIEW vw_volatility_stddev AS
SELECT ticker,
    STDDEV(daily_return) AS volatility
FROM (
    SELECT ticker, date,
    (Close - LAG(Close) OVER (PARTITION BY ticker ORDER BY date))
    / LAG(Close) OVER (PARTITION BY ticker ORDER BY date) * 100
    AS daily_return
    FROM stock_prices_ymd
) AS returns
GROUP BY ticker
ORDER BY volatility DESC;

-- avg closing price of each stock

CREATE VIEW vw_avg_closing_price AS
SELECT ticker,
    ROUND(AVG(close), 3) AS avg_closing_price
FROM stock_prices_ymd
GROUP BY ticker
ORDER BY avg_closing_price DESC;

-- sectorwise avg returns

CREATE VIEW vw_sector_avg_return AS
SELECT sector,
    ROUND(AVG(((open - close) / open) * 100), 2) AS avg_return
FROM stock_prices_ymd
GROUP BY sector
ORDER BY avg_return DESC;

-- overall returns of each stock

CREATE VIEW vw_overall_returns AS
SELECT ticker,
    ROUND(((MAX(close) - MIN(close)) / MIN(close)) * 100, 2) AS returns
FROM stock_prices_ymd
GROUP BY ticker
ORDER BY returns DESC;

SHOW FULL TABLES IN stock_analytics WHERE TABLE_TYPE LIKE 'VIEW';

