CREATE TABLE transactions (
    id          UUID           NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    description VARCHAR(255)   NOT NULL,
    amount      NUMERIC(19, 2) NOT NULL,
    type        VARCHAR(20)    NOT NULL,
    category    VARCHAR(100),
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
