-- Create tags table
CREATE TABLE IF NOT EXISTS tags (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

-- Create menu_tags join table
CREATE TABLE IF NOT EXISTS menu_tags (
    menu_id INTEGER NOT NULL,
    tag_id BIGINT NOT NULL,
    PRIMARY KEY (menu_id, tag_id),
    CONSTRAINT fk_menu_tags_menu FOREIGN KEY (menu_id) REFERENCES menu (id) ON DELETE CASCADE,
    CONSTRAINT fk_menu_tags_tag FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
);
