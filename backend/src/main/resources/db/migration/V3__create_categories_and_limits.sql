CREATE TABLE categories (
    id         UUID          NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE limits (
    id          UUID           NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    category_id UUID           NOT NULL REFERENCES categories(id),
    amount      NUMERIC(19, 2) NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
