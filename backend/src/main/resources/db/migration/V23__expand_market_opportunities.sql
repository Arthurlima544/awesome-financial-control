-- US-97: Expand Market Opportunities with Logos and Daily Changes
ALTER TABLE market_opportunities ADD COLUMN change_percent NUMERIC(19, 4);
ALTER TABLE market_opportunities ADD COLUMN logo_url VARCHAR(255);
ALTER TABLE market_opportunities ADD COLUMN sector VARCHAR(255);
