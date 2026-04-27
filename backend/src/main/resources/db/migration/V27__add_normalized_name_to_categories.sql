ALTER TABLE categories ADD COLUMN normalized_name VARCHAR(255);

UPDATE categories SET normalized_name = LOWER(name);

CREATE INDEX idx_categories_normalized_name ON categories(normalized_name);
