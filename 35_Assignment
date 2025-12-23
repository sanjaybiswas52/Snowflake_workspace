CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.employees(
 customer_id int,
 first_name varchar(50),
 last_name varchar(50),
 email varchar(50),
 age int,
 department varchar(50)
 );

CREATE OR REPLACE STAGE copy_db.public.aws_stage_copy2
    url='s3://snowflake-assignments-mc/copyoptions/example1';

list @copy_db.public.aws_stage_copy2;

copy into OUR_FIRST_DB.public.employees
    from @copy_db.public.aws_stage_copy2
    file_format = (type=csv field_delimiter=',' skip_header=1)
    pattern='.*employees.*'
    ON_ERROR = 'CONTINUE';

SELECT * FROM OUR_FIRST_DB.public.employees

 LIST @copy_db.public.aws_stage_copy2;
 select $1, $2, $3, $4, $5,$6 from @copy_db.public.aws_stage_copy2;

 --DESC STAGE @OUR_FIRST_DB.public.employees;

--SHOW @OUR_FIRST_DB.public.employees

