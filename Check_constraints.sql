
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
INSERT INTO dim_payment_tmp VALUES
(301, 'Credit Card', 'Visa'),
(302, 'UPI', NULL),
(303, 'Debit Card', 'RuPay'),
(304, 'Cash', NULL),
(305, 'Points', NULL);
ALTER TABLE dim_payment SWAP WITH dim_payment_tmp;

ALTER TABLE dim_payment ADD CONSTRAINT pk_payment primary key (PAYMENT_ID);

----------------------------------------
ALTER TABLE fact_orders 
DROP CONSTRAINT fk_customer;

ALTER TABLE fact_orders 
ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id) ON DELETE CASCADE;

---------------
ALTER TABLE fact_orders ADD COLUMN update_date TIMESTAMP;

INSERT INTO fact_orders 
(order_id, customer_id, product_id, date_id, store_id, employee_id, payment_id, shipping_id, promo_id, quantity, amount, update_date)
VALUES
(1001, 1, 101, '2026-02-01', 11, 201, 301, 401, 501, 1, 25000.00, CURRENT_TIMESTAMP),
(1002, 2, 102, '2026-02-05', 12, 202, 302, 402, 502, 2, 120000.00, CURRENT_TIMESTAMP),
(1003, 1, 102, '2026-02-06', 11, 201, 301, 401, 501, 1, 60000.00, CURRENT_TIMESTAMP),
(1004, 2, 101, '2026-02-07', 12, 202, 302, 402, 502, 3, 75000.00, CURRENT_TIMESTAMP),
(1005, 1, 101, '2026-02-08', 11, 201, 301, 401, 501, 2, 50000.00, CURRENT_TIMESTAMP),
(1006, 2, 102, '2026-02-09', 12, 202, 302, 402, 502, 1, 60000.00, CURRENT_TIMESTAMP),
(1007, 1, 101, '2026-02-10', 11, 201, 301, 401, 501, 1, 25000.00, CURRENT_TIMESTAMP),
(1008, 2, 102, '2026-02-11', 12, 202, 302, 402, 502, 2, 120000.00, CURRENT_TIMESTAMP),
(1009, 1, 102, '2026-02-12', 11, 201, 301, 401, 501, 1, 60000.00, CURRENT_TIMESTAMP),
(1010, 2, 101, '2026-02-13', 12, 202, 302, 402, 502, 3, 75000.00, CURRENT_TIMESTAMP);
-- Continue similarly until you reach 50 rows
;

SELECT order_id, count(*) FROM fact_orders GROUP BY order_id HAVING count(*) > 1
-- Remove duplicate records from fact_orders
CREATE OR REPLACE TABLE fact_orders
AS 
SELECT order_id, customer_id, product_id, date_id, store_id, employee_id, payment_id, shipping_id, promo_id, quantity, amount, update_date
FROM fact_orders GROUP BY (order_id, customer_id, product_id, date_id, store_id, employee_id, payment_id, shipping_id, promo_id, quantity, amount, update_date)

-- Note :it drops and recreates the table. That means all metadata — including primary keys, foreign keys, constraints, clustering keys, comments, tags, grants — are lost. Snowflake doesn’t have a syntax to “preserve constraints” automatically in a CREATE OR REPLACE … AS SELECT (CTAS) statement. 

SELECT * FROM fact_orders

CREATE OR REPLACE TABLE fact_orders_dedup (
    order_id INT PRIMARY KEY,
    customer_id INT,-- REFERENCES dim_customer(customer_id),
    product_id INT REFERENCES dim_product(product_id),
    date_id DATE,
    store_id INT REFERENCES dim_store(store_id),
    employee_id INT REFERENCES dim_employee(employee_id),
    payment_id INT REFERENCES dim_payment(payment_id),
    shipping_id INT REFERENCES dim_shipping(shipping_id),
    promo_id INT REFERENCES dim_promotion(promo_id),
    quantity INT,
    amount NUMBER(10,2),
    update_date TIMESTAMP
)
AS
SELECT DISTINCT order_id, customer_id, product_id, date_id, store_id, employee_id, payment_id, shipping_id, promo_id, quantity, amount, CURRENT_TIMESTAMP()
FROM fact_orders ;

select distinct customer_id from fact_orders where order_id = '1001'

SELECT * FROM dim_customer
    

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
