CREATE TYPE transaction_type AS ENUM ('INCOME', 'EXPENSE');

CREATE TABLE transactions (
    id          UUID         NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    amount      NUMERIC(19, 2) NOT NULL,
    type        transaction_type NOT NULL,
    category    VARCHAR(100),
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
