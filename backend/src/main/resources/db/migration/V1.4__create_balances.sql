CREATE TABLE balances (
    student_id BIGINT PRIMARY KEY REFERENCES users(id),
    amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00
);