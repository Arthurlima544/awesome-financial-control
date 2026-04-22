CREATE TABLE templates (
    id UUID PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL
);
