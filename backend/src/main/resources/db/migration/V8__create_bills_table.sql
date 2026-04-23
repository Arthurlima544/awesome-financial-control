CREATE TABLE bills (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    amount DECIMAL(19, 2) NOT NULL,
    due_day INTEGER NOT NULL,
    category_id VARCHAR(255)
);
