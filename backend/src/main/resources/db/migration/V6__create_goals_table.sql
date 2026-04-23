CREATE TABLE goals (
    id             UUID           NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    name           VARCHAR(255)   NOT NULL,
    target_amount  NUMERIC(19, 2) NOT NULL,
    current_amount NUMERIC(19, 2) NOT NULL DEFAULT 0,
    deadline       TIMESTAMP WITH TIME ZONE NOT NULL,
    icon           VARCHAR(100),
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
