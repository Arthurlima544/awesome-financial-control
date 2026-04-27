ALTER TABLE bills ALTER COLUMN id SET DEFAULT uuid_generate_v4();

ALTER TABLE bills ADD COLUMN created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now();

ALTER TABLE bills ALTER COLUMN category_id TYPE UUID USING category_id::uuid;

ALTER TABLE bills ADD CONSTRAINT fk_bills_category
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

ALTER TABLE recurring_transactions
    ALTER COLUMN last_paid_at TYPE TIMESTAMP WITH TIME ZONE
    USING last_paid_at AT TIME ZONE 'UTC';

ALTER TABLE templates
    ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE
    USING created_at AT TIME ZONE 'UTC';
