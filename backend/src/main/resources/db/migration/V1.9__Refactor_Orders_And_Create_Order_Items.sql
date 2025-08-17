ALTER TABLE orders DROP COLUMN items;

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    menu_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    price NUMERIC(19, 2) NOT NULL,
    CONSTRAINT fk_order
        FOREIGN KEY(order_id)
            REFERENCES orders(id),
    CONSTRAINT fk_menu
        FOREIGN KEY(menu_id)
            REFERENCES menu(id)
); 