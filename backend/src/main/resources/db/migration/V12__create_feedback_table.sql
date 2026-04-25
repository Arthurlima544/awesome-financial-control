CREATE TABLE feedbacks (
    id          UUID           NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id     UUID           NOT NULL,
    rating      INT            NOT NULL CHECK (rating >= 1 AND rating <= 5),
    message     TEXT,
    app_version VARCHAR(20)    NOT NULL,
    platform    VARCHAR(20)    NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
