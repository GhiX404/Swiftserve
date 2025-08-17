-- First, update existing data. We assume 'PENDING' is a common initial state.
-- You might need to add more UPDATE statements for other string-based statuses.
UPDATE orders SET status = 'PENDING' WHERE status = 'PENDING';
UPDATE orders SET status = 'PAID' WHERE status = 'PAID';


-- Now, alter the column type
ALTER TABLE orders ALTER COLUMN status TYPE VARCHAR(255); 