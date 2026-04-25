CREATE TABLE market_opportunities (
    ticker VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(20),
    current_price DECIMAL(19, 4),
    dividend_yield DECIMAL(19, 4),
    pe_ratio DECIMAL(19, 4),
    pvp_ratio DECIMAL(19, 4),
    dy_vs_cdi DECIMAL(19, 4),
    last_updated TIMESTAMP WITH TIME ZONE
);
