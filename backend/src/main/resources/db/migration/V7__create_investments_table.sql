CREATE TABLE investments (
    id             UUID           NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    name           VARCHAR(255)   NOT NULL,
    ticker         VARCHAR(50),
    type           VARCHAR(20)    NOT NULL,
    quantity       NUMERIC(19, 4) NOT NULL,
    avg_cost       NUMERIC(19, 2) NOT NULL,
    current_price  NUMERIC(19, 2) NOT NULL,
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
