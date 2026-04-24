ALTER TABLE transactions ADD COLUMN is_passive BOOLEAN DEFAULT FALSE;
ALTER TABLE transactions ADD COLUMN investment_id UUID;
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_investment FOREIGN KEY (investment_id) REFERENCES investments (id);

ALTER TABLE recurring_transactions ADD COLUMN is_passive BOOLEAN DEFAULT FALSE;
ALTER TABLE recurring_transactions ADD COLUMN investment_id UUID;
ALTER TABLE recurring_transactions ADD CONSTRAINT fk_recurring_transactions_investment FOREIGN KEY (investment_id) REFERENCES investments (id);
