create schema gold_layer;

-- dividing into Star Schema
-- Fact table = fact_sales
--dimensional tables
-- 1) product_details
-- 2) customer_details
-- 3) order_details

create table product_details(
product_id int autoincrement  start 100 increment 1,
product_category varchar(20),
product_name varchar(20)
);

-- procedure to insert rows in products_details
create or replace procedure insert_to_dim_products(new_dim_table string,source_table string)
returns string
language sql 
as
$$
declare 
insert_stmt string;
task_initiated datetime;
task_finished datetime;
count_rows int;
to_get_user string;
begin

            task_initiated := current_timestamp();

            to_get_user := select current_user();

            insert_stmt := 

                            ' insert into ' ||  new_dim_table || ' (product_category,product_name)
                             select distinct product_category,product_name from sales_details.silver_layer. ' || source_table;

            execute immediate insert_stmt;

            count_rows := sqlrowcount;


            task_finished := current_timestamp();

            insert into sales_details.bronze_layer.audit_table 
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:new_dim_table,null,'Rows_loading',:count_rows,'sucess',:task_initiated,:task_finished,null);


            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Inserted_rows_into : ' || :new_dim_table || char(10) ||
            'no_of_rows_loaded : ' || :count_rows || char(10) ||
            'status : sucess'); 

        return new_dim_table || ' created sucessfully';

    exception
    when other then 

            task_finished := current_timestamp();
            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,source_count,status,start_time,end_time,error_message)
            values (:new_dim_table,null,'Rows_loading',null,'Failed',:task_initiated,:task_finished,:sqlerrm);

            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Inserted_rows_into : ' || :new_dim_table || char(10) ||
            ' status : failed' || char(10) ||
            ' error message' || :sqlerrm);

        return 'failed to create new table ' || new_dim_table;

end;
$$;

-- calling the procedure 
call insert_to_dim_products('product_details','sales_data');

-- check the rows
select * from product_details;

-- To check audit_table
select * from sales_details.bronze_layer.audit_table;


-- creating table to store Customer Details

create table customer_details(
customer_id varchar(15),
customer_name varchar(25),
age int,
gender varchar(15),
region varchar(20),
city varchar(20)
);

-- procedure to insert rows in customer_details Table

create or replace procedure insert_to_dim_customers(new_dim_table string,source_table string)
returns string
language sql 
as
$$
declare 
insert_stmt string;
task_initiated datetime;
task_finished datetime;
count_rows int;
to_get_user string;
begin

            task_initiated := current_timestamp();

            to_get_user := current_user();

            insert_stmt := 
                            'merge into ' || new_dim_table || ' as fd
using (select distinct customer_id ,customer_name,age,gender,region,city from sales_details.silver_layer. '|| source_table|| ' ) as cd
on fd.customer_id = cd.customer_id


                when not matched then 
                insert(customer_id ,customer_name,age,gender,region,city)
                values (cd.customer_id ,cd.customer_name,cd.age,cd.gender,cd.region,cd.city)';
                           
            execute immediate insert_stmt;

            count_rows := sqlrowcount;


            task_finished := current_timestamp();

            insert into sales_details.bronze_layer.audit_table 
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:new_dim_table,null,'Rows_loading',:count_rows,'sucess',:task_initiated,:task_finished,null);


            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Insert_rows_into : ' || :new_dim_table || char(10) ||
            'no_of_rows_loaded : ' || :count_rows || char(10) ||
            'status : sucess'); 

        return 'Rows loaded into ' || new_dim_table || '  sucessfully';

    exception
    when other then 

            task_finished := current_timestamp();
            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:new_dim_table,null,'Rows_loading',null,'Failed',:task_initiated,:task_finished,:sqlerrm);

            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Insert_rows_into : ' || :new_dim_table || char(10) ||
            ' status : failed' || char(10) ||
            ' error message' || :sqlerrm);

        return 'failed to load_rows into ' || new_dim_table;

end;
$$;



call insert_to_dim_customers('customer_details','sales_data');


select * from customer_details;


select * from sales_details.bronze_layer.audit_table;




-- creating table to store order_details

create or replace table order_details(
order_id varchar(10),
order_date date,
payment_method varchar(20),
return_flag boolean,
order_status varchar(15)
);



desc table sales_details.silver_layer.sales_data;

-- procedure to insert rows in order_details Table


create or replace procedure insert_to_dim_orders(new_dim_table string,source_table string)
returns string
language sql 
as
$$
declare 
insert_stmt string;
task_initiated datetime;
task_finished datetime;
count_rows int;
to_get_user string;
begin

            task_initiated := current_timestamp();

            to_get_user := current_user();

            insert_stmt := 
                            'merge into ' || new_dim_table ||' as od
                            using sales_details.silver_layer. '|| source_table ||' as sd
                            on od.order_id = sd.order_id

                            when not matched then 
                            insert (order_id,order_date,payment_method,return_flag,order_status)
                            values (order_id,new_order_date,payment_method,return_flag,order_status)';

            execute immediate insert_stmt;

            count_rows := sqlrowcount;


            task_finished := current_timestamp();

            insert into sales_details.bronze_layer.audit_table 
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:new_dim_table,null,'Rows_loading',:count_rows,'sucess',:task_initiated,:task_finished,null);


            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Insert_rows_into : ' || :new_dim_table || char(10) ||
            'no_of_rows_loaded : ' || :count_rows || char(10) ||
            'status : sucess'); 

        return new_dim_table || ' created sucessfully';

    exception
    when other then 

            task_finished := current_timestamp();
            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message,action)
            values (:new_dim_table,null,'Rows_loading',null,'failed',:task_initiated,:task_finished,:sqlerrm,'Failed_Create');

            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Insert_rows_into : ' || :new_dim_table || char(10) ||
            ' status : failed' || char(10) ||
            ' error message' || :sqlerrm);

        return 'failed to create new table ' || new_dim_table;

end;
$$;

call insert_to_dim_orders('order_details','sales_data');

select * from order_details;

select * from sales_details.bronze_layer.audit_table;


-- Creating fact_table to store sales_data

create or replace table fact_sales_data(
order_id varchar(15),
customer_id varchar(15),
order_date date,
product_id int,
quantity int,
unit_price decimal(10,2),
discount_pct decimal(6,2),
total_amount decimal(10,2),
profit decimal(10,2),
shipping_cost decimal(6,2),
customer_satisfaction int,
days_to_ship int
);

-- procedure to insert rows in fact_sales_data Table

create or replace procedure insert_to_fact_table(new_fact_table string,source_table string,reference_table string)
returns string
language sql 
as
$$
declare 
insert_stmt string;
task_initiated datetime;
task_finished datetime;
count_rows int;
to_get_user string;
begin

            task_initiated := current_timestamp();


            to_get_user := current_user();

            insert_stmt := 
            'merge into ' ||  new_fact_table || ' as fd using (select s.order_id,s.customer_id,s.new_order_date,p.product_id,s.quantity,s.unit_price,s.discount_percentage,s.sales_amount,s.profit,s.shipping_cost,s.customer_satisfaction,s.days_to_ship from sales_details.silver_layer. ' || source_table || ' s join ' || reference_table || ' p on s.product_name = p.product_name) as src on 
fd.order_id = src.order_id


when not matched then 
insert(order_id,customer_id,order_date,product_id,quantity,unit_price,discount_pct,total_amount,profit,shipping_cost,customer_satisfaction,days_to_ship)

values (src.order_id,src.customer_id,src.new_order_date,src.product_id,src.quantity,src.unit_price,src.discount_percentage,src.sales_amount,src.profit,src.shipping_cost,src.customer_satisfaction,src.days_to_ship) ';
                        
                            
            execute immediate insert_stmt;

            count_rows := sqlrowcount;


            task_finished := current_timestamp();

            insert into sales_details.bronze_layer.audit_table 
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:new_fact_table,null,'Rows_loading',:count_rows,'sucess',:task_initiated,:task_finished,null);


            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Insert_rows_into : ' || :new_fact_table || char(10) ||
            'no_of_rows_loaded : ' || :count_rows || char(10) ||
            'status : sucess'); 

        return new_fact_table || ' created sucessfully';

    exception
    when other then 

            task_finished := current_timestamp();
            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:new_fact_table,null,'Rows_loading',null,'failed',:task_initiated,:task_finished,:sqlerrm);

            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Insert_rows_into : ' || :new_fact_table || char(10) ||
            ' status : failed' || char(10) ||
            ' error message' || :sqlerrm);

        return 'failed to create new table ' || new_fact_table;

end;
$$;




call insert_to_fact_table('fact_sales_data','sales_data','product_details');



select * from sales_details.bronze_layer.audit_table;
