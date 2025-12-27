-- Create Bucket in AWS S3 "snowflake-buck01"
-- Create role on IAM
/* Trust relationship
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::666096284725:root"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "666096284725"
                }
            }
        }
    ]
}
*/

  
// Create storage integration object on snowflake

create or replace storage integration s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::666096284725:role/snowflake-S3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-buck01/csv/', 's3://snowflake-buck01/json/')
   COMMENT = 'This an optional comment' ;

desc integration s3_buck_int;

-- STORAGE_AWS_IAM_USER_ARN = arn:aws:iam::482849671603:user/397d1000-s
-- STORAGE_AWS_EXTERNAL_ID = IF60811_SFCRole=2_jcDLYtngALyZgt45jS7OLYVTttg=

/* Modify Trust relationship on AWS role  

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::666096284725:role/snowflake-S3-role"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "IF60811_SFCRole=2_jcDLYtngALyZgt45jS7OLYVTttg="
                }
            }
        }
    ]
}
// See storage integration properties to fetch external_id so we can update it in S3
DESC integration s3_int;

-- Create External Stage
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.s3_stage
  URL = 's3://snowflake-buck01/'
  STORAGE_INTEGRATION = s3_int
  FILE_FORMAT = (TYPE = PARQUET);

-- Export Data (COPY INTO)

COPY INTO @s3_stage/parquet/orders/
FROM OUR_FIRST_DB.PUBLIC.ORDERS
OVERWRITE = TRUE;

