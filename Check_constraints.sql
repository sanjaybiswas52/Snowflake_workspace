
CREATE DATABASE REDBIRD;
CREATE SCHEMA REDBIRD.DEV;
USE DATABASE REDBIRD;
USE SCHEMA DEV;
-- Customer Dimension
CREATE OR REPLACE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name STRING,
    segment STRING,
    region STRING
);

-- Product Dimension
CREATE OR REPLACE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name STRING,
    category STRING,
    brand STRING
);

-- Date Dimension
CREATE OR REPLACE TABLE dim_date (
    date_id DATE PRIMARY KEY,
    fiscal_period STRING,
    day_of_week STRING
);

-- Store Dimension
CREATE OR REPLACE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name STRING,
    city STRING,
    state STRING,
    country STRING
);

-- Employee Dimension
CREATE OR REPLACE TABLE dim_employee (
    employee_id INT PRIMARY KEY,
    employee_name STRING,
    department STRING
);

-- Payment Dimension
CREATE OR REPLACE TABLE dim_payment (
    payment_id INT PRIMARY KEY,
    payment_type STRING,
    card_type STRING
);

-- Shipping Dimension
CREATE OR REPLACE TABLE dim_shipping (
    shipping_id INT PRIMARY KEY,
    carrier STRING,
    method STRING
);

-- Promotion Dimension
CREATE OR REPLACE TABLE dim_promotion (
    promo_id INT PRIMARY KEY,
    promo_code STRING,
    campaign STRING
);

--- Create Fact Table (Orders)
CREATE OR REPLACE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES dim_customer(customer_id),
    product_id INT REFERENCES dim_product(product_id),
    date_id DATE REFERENCES dim_date(date_id),
    store_id INT REFERENCES dim_store(store_id),
    employee_id INT REFERENCES dim_employee(employee_id),
    payment_id INT REFERENCES dim_payment(payment_id),
    shipping_id INT REFERENCES dim_shipping(shipping_id),
    promo_id INT REFERENCES dim_promotion(promo_id),
    quantity INT,
    amount NUMBER(10,2)
);


-- Insert Sample Data
-- Customers
INSERT INTO dim_customer VALUES 
(1, 'Alice', 'Retail', 'North'),
(2, 'Bob', 'Wholesale', 'South');

-- Products
INSERT INTO dim_product VALUES 
(101, 'Laptop', 'Electronics', 'Dell'),
(102, 'Phone', 'Electronics', 'Apple');

-- Dates
INSERT INTO dim_date VALUES 
('2026-02-01', 'Q1-2026', 'Monday'),
('2026-02-05', 'Q1-2026', 'Friday');

-- Stores
INSERT INTO dim_store VALUES 
(11, 'Delhi Store', 'Delhi', 'Delhi', 'India'),
(12, 'Mumbai Store', 'Mumbai', 'Maharashtra', 'India');

-- Employees
INSERT INTO dim_employee VALUES 
(201, 'Sanjay', 'Sales'),
(202, 'Ravi', 'Support');

-- Payments
INSERT INTO dim_payment VALUES 
(301, 'Credit Card', 'Visa'),
(302, 'UPI', NULL);

-- Shipping
INSERT INTO dim_shipping VALUES 
(401, 'FedEx', 'Air'),
(402, 'BlueDart', 'Ground');

-- Promotions
INSERT INTO dim_promotion VALUES 
(501, 'NEWYEAR', 'Holiday Campaign'),
(502, 'FLASHSALE', 'Weekend Sale');

-- Orders (Fact Table)
INSERT INTO fact_orders VALUES 
(1001, 1, 101, '2026-02-01', 11, 201, 301, 401, 501, 1, 25000.00),
(1002, 2, 102, '2026-02-05', 12, 202, 302, 402, 502, 2, 120000.00);

-- Constraint Violation Check
DELETE FROM dim_customer WHERE customer_id = 1;

-- If you want cascading deletes:

ALTER TABLE fact_orders 
DROP CONSTRAINT fk_customer;

ALTER TABLE fact_orders 
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id) ON DELETE CASCADE;




---------------------- END ---------------
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
