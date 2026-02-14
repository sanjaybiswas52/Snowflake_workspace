USE DATABASE HR
-- Create Master Table (Customers)
CREATE OR REPLACE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name STRING,
    email STRING
);

-- Create Child Table (Orders) with Foreign Key Reference
CREATE OR REPLACE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount NUMBER(10,2),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert Sample Data
-- Insert into master table
INSERT INTO customers VALUES 
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com');

-- Insert into child table
INSERT INTO orders VALUES 
(105, 6, '2026-02-01', 250.00),
(102, 1, '2026-02-05', 300.00),
(103, 2, '2026-02-10', 150.00);

SELECT * FROM orders
SELECT * FROM CUSTOMERS
-- Check Constraint Violation
SELECT * FROM HR.INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
-- List all primary keys in the current database
SHOW PRIMARY KEYS IN DATABASE;

-- List all primary keys in the current schema
SHOW PRIMARY KEYS IN SCHEMA;

-- List all primary keys across the account
SHOW PRIMARY KEYS IN ACCOUNT;

-- This will fail because customer_id = 1 is referenced in orders
DROP TABLE customers
