
-- creating tables for bronze_layer


-- Bronzelayer-main-table

create or replace table sales_details.bronze_layer.sales_data(
order_id varchar(25),
order_date varchar(25),
customer_id varchar(25),
customer_name varchar(25),
age int,
gender varchar(15),
region varchar(15),
city varchar(15),
product_category varchar(20),
product_name varchar(15),
quantity int,
unit_price decimal(10,2),
discount_percentage decimal(5,2),
sales_amount decimal(10,2),
profit decimal(10,2),
shipping_cost decimal(10,2),
payment_method varchar(150),
customer_satisfaction decimal(5,2),
return_flag varchar(10),
order_status varchar(20),
days_to_ship int
);

desc table sales_details.bronze_layer.sales_data;


-- creating audit_table
create or replace table  sales_details.bronze_layer.audit_table(
TABLEE_NAME varchar(200),
FILEE_NAME varchar(200),
ACTION_TYPE varchar(200),
SOURCE_COUNT int,
STATUS varchar(50),
START_TIME datetime,
END_TIME datetime,
ERROR_MESSAGE varchar(250)
);


desc table sales_details.bronze_layer.audit_table;