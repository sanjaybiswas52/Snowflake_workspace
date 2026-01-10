-- Remove caching just to have a fair test -- Part 2

ALTER SESSION SET USE_CACHED_RESULT=FALSE; -- disable global caching
ALTER warehouse compute_wh suspend;
ALTER warehouse compute_wh resume;

-- Prepare table
CREATE OR REPLACE TRANSIENT DATABASE ORDERS;

CREATE OR REPLACE SCHEMA TPCH_SF100;

CREATE OR REPLACE TABLE TPCH_SF100.ORDERS AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS;

SELECT * FROM ORDERS LIMIT 100;

-- Example statement view -- 
SELECT
YEAR(O_ORDERDATE) AS YEAR,
MAX(O_COMMENT) AS MAX_COMMENT,
MIN(O_COMMENT) AS MIN_COMMENT,
MAX(O_CLERK) AS MAX_CLERK,
MIN(O_CLERK) AS MIN_CLERK
FROM ORDERS.TPCH_SF100.ORDERS
GROUP BY YEAR(O_ORDERDATE)
ORDER BY YEAR(O_ORDERDATE);


-- Create materialized view
CREATE OR REPLACE MATERIALIZED VIEW ORDERS_MV
AS 
SELECT
YEAR(O_ORDERDATE) AS YEAR,
MAX(O_COMMENT) AS MAX_COMMENT,
MIN(O_COMMENT) AS MIN_COMMENT,
MAX(O_CLERK) AS MAX_CLERK,
MIN(O_CLERK) AS MIN_CLERK
FROM ORDERS.TPCH_SF100.ORDERS
GROUP BY YEAR(O_ORDERDATE);

SHOW MATERIALIZED VIEWS;

-- Query view
SELECT * FROM ORDERS_MV
ORDER BY YEAR;

-- UPDATE or DELETE values
UPDATE ORDERS
SET O_CLERK='Clerk#99900000' 
WHERE O_ORDERDATE='1992-01-01';

   -- Test updated data --
-- Example statement view -- 
SELECT
YEAR(O_ORDERDATE) AS YEAR,
MAX(O_COMMENT) AS MAX_COMMENT,
MIN(O_COMMENT) AS MIN_COMMENT,
MAX(O_CLERK) AS MAX_CLERK,
MIN(O_CLERK) AS MIN_CLERK
FROM ORDERS.TPCH_SF100.ORDERS
GROUP BY YEAR(O_ORDERDATE)
ORDER BY YEAR(O_ORDERDATE);

-- Query view
SELECT * FROM ORDERS_MV
ORDER BY YEAR;

SHOW MATERIALIZED VIEWS;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY())
WHERE MATERIALIZED_VIEW_NAME = 'ORDERS_MV';

-- Suspend / Resume Auto Refresh
----------------------------------
ALTER MATERIALIZED VIEW sales_mv SUSPEND;
ALTER MATERIALIZED VIEW sales_mv RESUME;

-- Recommended Alternative: Dynamic Tables (Modern)
-----------------------------------------------
CREATE DYNAMIC TABLE redbird.public.my_table
TARGET_LAG = '5 minutes'
WAREHOUSE = compute_wh
AS
select category, max(profit) as max_profit from our_first_db.public.orders
group by category
order by 2 desc;

select * from redbird.public.my_table

SHOW DYNAMIC TABLES IN DATABASE redbird;


-- Find Dynamic table information
SELECT table_name,
       target_lag,
       last_refresh_time,
       CURRENT_TIMESTAMP AS current_time,
       DATEDIFF('minute', last_refresh_time, CURRENT_TIMESTAMP) AS minutes_since_last_refresh
FROM INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE table_schema = 'PUBLIC'
  AND table_name = 'MY_TABLE';

USE DATABASE REDBIRD;
USE SCHEMA PUBLIC;
SHOW DYNAMIC TABLES IN SCHEMA PUBLIC;

SELECT table_catalog, table_schema, table_name, target_lag, last_refresh_time
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLES
WHERE table_name = 'MY_TABLE';

SELECT CASE
         WHEN DATEDIFF('minute', last_refresh_time, CURRENT_TIMESTAMP) > 5
         THEN 'Refresh Delayed'
         ELSE 'On Schedule'
       END AS refresh_status
FROM INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE table_schema = 'PUBLIC'
  AND table_name = 'MY_TABLE';

--Modify TARGET_LAG
ALTER DYNAMIC TABLE MY_TABLE
SET TARGET_LAG = '10 minutes';

--Change Warehouse (often done together)
ALTER DYNAMIC TABLE sales_dt
SET WAREHOUSE = compute_wh_large;

--Verify Current Settings
DESCRIBE DYNAMIC TABLE sales_dt;
SHOW DYNAMIC TABLES LIKE 'SALES_DT';

ALTER DYNAMIC TABLE redbird.public.my_table SUSPEND;



