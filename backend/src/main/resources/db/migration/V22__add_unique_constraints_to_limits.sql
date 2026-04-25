-- US-95: Unique Categories and Strict Limits
-- Enforce only one limit per category
ALTER TABLE limits ADD CONSTRAINT unique_category_limit UNIQUE (category_id);
