CREATE INDEX idx_transactions_occurred_at ON transactions(occurred_at DESC);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_is_passive ON transactions(is_passive);
CREATE INDEX idx_transactions_investment_id ON transactions(investment_id) WHERE investment_id IS NOT NULL;
CREATE INDEX idx_recurring_next_due_at ON recurring_transactions(next_due_at);
CREATE INDEX idx_recurring_active ON recurring_transactions(active);
