-- This script is for initial, manual database setup.
-- For production and automated environments, rely on Flyway migrations.

-- Drop existing tables in reverse order of creation to handle dependencies
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS rfid_mappings;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS menu_tags;


-- Users table
-- Reflects the User entity.
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    fcm_token VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Roles table for RBAC
-- Reflects the Role entity.
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL
);

-- Join table for Users and Roles
-- Reflects the @ManyToMany relationship in the User entity.
CREATE TABLE user_roles (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Menu table for canteen items
-- Reflects the Menu entity.
CREATE TABLE menu (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    price NUMERIC(19, 2) NOT NULL,
    stock INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
-- Reflects the Order entity.
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES users(id),
    status VARCHAR(255),
    total_amount NUMERIC(19, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Order Items table
-- Reflects the OrderItem entity, linking Orders and Menu items.
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_id BIGINT NOT NULL REFERENCES menu(id),
    quantity INTEGER NOT NULL,
    price NUMERIC(19, 2) NOT NULL
);

-- Transactions table
-- Reflects the Transaction entity.
CREATE TABLE transactions (
    user_id INTEGER NOT NULL REFERENCES users(id),
    order_id INTEGER NOT NULL REFERENCES orders(id),
    amount NUMERIC(19, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (user_id, order_id)
);

-- RFID mappings table
-- Reflects the RfidMapping entity.
CREATE TABLE rfid_mappings (
    rfid_uid VARCHAR(50) PRIMARY KEY,
    student_id INTEGER UNIQUE REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tags for categorizing menu items
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

-- Join table for Menu and Tags
CREATE TABLE menu_tags (
    menu_id BIGINT NOT NULL REFERENCES menu(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (menu_id, tag_id)
);


-- Seed initial data
-- Default roles required by the application.
INSERT INTO roles(name) VALUES('ROLE_STUDENT');
INSERT INTO roles(name) VALUES('ROLE_STAFF');

