-- creating new_schema for Silver_layer

create schema silver_layer;


-- creating new_sales table in silver_layer using bronze_layer table

create  or replace table  sales_data
like sales_details.bronze_layer.sales_data;



-- creating procedure to insert rows in new silver_layer Table 

create or replace procedure insert_into_silver_table(bronze_table_name string,silver_table_name string)
returns string
language sql 
as
$$
declare 
insert_stmt string;
task_initiated datetime;
task_finished datetime;
count_rows int;
TO_GET_USER STRING;
begin
        task_initiated := current_timestamp();


        TO_GET_USER := CURRENT_USER();
        
        insert_stmt := 'merge into ' || silver_table_name || ' as target    using ' || bronze_table_name || ' as                                                   source on target.order_id = source.order_id when not matched then
insert(order_id,order_date,customer_id,customer_name,age,gender,region,city,product_category,product_name,quantity,unit_price,discount_percentage,sales_amount,profit,shipping_cost,payment_method,customer_satisfaction,return_flag,order_status,days_to_ship)
values (source.order_id,source.order_date,source.customer_id,source.customer_name,source.age,source.gender,source.region,source.city,source.product_category,source.product_name,source.quantity,source.unit_price,source.discount_percentage,source.sales_amount,source.profit,source.shipping_cost,source.payment_method,source.customer_satisfaction,source.return_flag,source.order_status,source.days_to_ship)';

        
    execute immediate insert_stmt;

    count_rows := sqlrowcount;

    task_finished := current_timestamp();

    insert into sales_details.bronze_layer.audit_table (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
        values (:silver_table_name,null,'Data_Loading',:count_rows,'Sucess',:task_initiated,:task_finished,null);


    call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
        'From_user : ' || :to_get_user || char(10) ||
        'loaded_to : ' || :silver_table_name || char(10) ||
        'no_of_rows_loaded : ' || :count_rows || char(10) ||
        'status : sucess');
        
    return 'loaded to silver_layer_table sucessfully';

exception
when other then 

task_finished := current_timestamp();
insert into sales_details.bronze_layer.audit_table (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
        values (:silver_table_name,null,'Data_Loading',null,'Failed',:task_initiated,:task_finished,:sqlerrm);

call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
        'From_user : ' || :to_get_user || char(10) ||
        'loaded_to : ' || :silver_table_name || char(10) ||
        ' status : failed' || char(10) ||
        ' error message' || :sqlerrm);

    return sqlerrm;

end;
$$;


-- call the procudure to insert rows
call insert_into_silver_table('sales_details.bronze_layer.sales_data','sales_details.silver_layer.sales_data');


select * from sales_data;



-- creating a new procedure to transform gender column

create or replace procedure transform_gender(table_name string,column_name string)
returns int
language sql
as
$$
declare
sql_stmt string;
total_rows int;
task_initiated datetime;
task_finished datetime;
to_get_user string;
begin

            task_initiated := current_timestamp();

            to_get_user := current_user();

            sql_stmt := 
            'update ' || table_name || ' set '  ||  column_name  || ' = case  
              when ' || column_name || ' in ( ''male'',''M'',''m'',''MALE'' ) then ''Male'' '||
            ' when ' || column_name || ' in ( ''female'',''F'',''f'',''FEMALE'' ) then ''Female'' ' ||
           ' else ' || column_name ||
            ' end';

            execute immediate sql_stmt;
            
            total_rows := sqlrowcount;

            task_finished := current_timestamp();


        insert into sales_details.bronze_layer.audit_table      
        (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
        values (:table_name,null,'Transform_Data',:total_rows,'Sucess',:task_initiated,:task_finished,null);

         call system$send_email('alert_user','subhashv9966@gmail.com','regarding_Transforming_data',
        'From_user : ' || :to_get_user || char(10) ||
        'Table_name : ' || :table_name || char(10) ||
        'Action_commited : Transform ' || :column_name || char(10) ||
        'count_of_transformed_rows : ' || :total_rows || char(10) ||
        'status : sucess'); 

        return 'Transformed Sucessfully ' || column_name;

exception
when other then

            task_finished := current_timestamp();
        insert into sales_details.bronze_layer.audit_table 
        (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
        values (:table_name,null,'Transform_Data',null,'Failed',:task_initiated,:task_finished,:sqlerrm);

        call system$send_email('alert_user','subhashv9966@gmail.com','regarding_Transforming_data',
        'From_user : ' || :to_get_user || char(10) ||
        'Table_name : ' || :table_name || char(10) ||
        'Action_commited : Transform ' || :column_name || char(10) ||
        ' status : Failed' || char(10) ||
        ' error message' || :sqlerrm);

        return 'Failed to Transform ' || column_name;

end;
$$;



call transform_gender('sales_data','gender');


select gender from sales_data;


-- Transform Order_Details

create or replace procedure transform_order_status(table_name string,column_name string)
returns string
language sql
as
$$
declare
sql_stmt1 string;
task_initiated datetime;
task_finished datetime;
total_rows int;
to_get_user string;

begin
                task_initiated := current_timestamp();

                to_get_user := current_user();

                sql_stmt1 := 

               ' update ' ||  table_name || 
' set ' || column_name || ' = case 
when '   ||  column_name || ' like ''%shipped%'' then   ''Shipped'' ' ||
' when ' || column_name || ' like ''%cancelled%'' then  ''cancelled'' ' ||  
' when ' || column_name || ' like ''%pending%'' then ''Pending'' ' ||
' when ' || column_name || ' like ''%Returned%'' then  ''Returned'' ' ||
' when ' || column_name || ' like ''%deliverd%'' then ''Deliverd'' ' || 
' else ' || column_name ||
' end ';


                execute immediate sql_stmt1;
                

                total_rows := sqlrowcount;


            task_finished := current_timestamp();


            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:table_name,null,'Transform_data',:total_rows,'Sucess',:task_initiated,:task_finished,null);



            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_Transforming_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Table_name : ' || :table_name || char(10) ||
            'Action_commited : Transform ' || :column_name || char(10) ||
            'count_of_transformed_rows : ' || :total_rows || char(10) ||
            'status : sucess'); 

            return ' transformed sucessfully';


exception
when other then

            task_finished := current_timestamp();
            
            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,source_count,status,start_time,end_time,error_message)
            values (:table_name,null,'Transform_data',null,'Failed',:task_initiated,:task_finished,:sqlerrm);


            call system$send_email('alert_user','subhashv9966@gmail.com','regarding_loading_data',
            'From_user : ' || :to_get_user || char(10) ||
            'Table_name : ' || :table_name || char(10) ||
            'Action_commited : Transform ' || :column_name || char(10) ||
            'count_of_transformed_rows : ' || :total_rows || char(10) ||
            'status : sucess'); 




        return 'Failed to transform';

end;
$$;




call transform_order_status('sales_data','order_status');


select * from sales_details.bronze_layer.audit_table;

-- add new date column

create or replace procedure add_new_date_column(table_name string,new_column_name string,old_column_name string)
returns string
language sql
as
$$
declare
sql_stmt1 string;
sql_stmt2 string;
sql_stmt3 string;
task_initiated datetime;
task_finished datetime;
count_rows int;
to_get_user string;
begin 

            task_initiated := current_timestamp();


            to_get_user := current_user();

            sql_stmt1 := ' alter table ' || table_name || ' add column ' || new_column_name || ' date';

            execute immediate sql_stmt1;


            sql_stmt2 :=
                        'update ' || table_name ||
                        ' set  ' || new_column_name || ' = case ' || 
                        ' when ' || old_column_name ||' like ''%/%'' ' || 
        ' then try_to_date( ' || old_column_name || ', ''dd/mm/yyyy'') ' || 
        ' when ' ||  old_column_name || ' like ''%,%'' ' ||
        ' then try_to_date(' || old_column_name || ' , '' mmmm dd, yyyy'')' || 
        ' when ' || old_column_name || ' like ''%-%'' ' || 
        ' then try_to_date( ' || old_column_name || ' , ''yyyy-mm-dd'')' ||
        ' else ' || old_column_name || '
            end';


        execute immediate sql_stmt2;
        count_rows := sqlrowcount;


        task_finished := current_timestamp();

        insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:table_name,null,'New_column',:count_rows,'Sucess',:task_initiated,:task_finished,null);



            call system$send_email('alert_user','subhashv9966@gmail.com','Regarding_Adding_New_Column',
            'From_user : ' || :to_get_user || char(10) ||
            'Table_name : ' || :table_name || char(10) ||
            'Action_commited : Add New Column ' || :new_column_name || char(10) ||
            'status : sucess'); 

            return new_column_name || ' Added sucessfully';


exception
when other then

            task_finished := current_timestamp();
            
            insert into sales_details.bronze_layer.audit_table
            (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
            values (:table_name,null,'New_column',null,'Failed',:task_initiated,:task_finished,:sqlerrm);


            call system$send_email('alert_user','subhashv9966@gmail.com','Regarding_Adding_New_Column',
            'From_user : ' || :to_get_user || char(10) ||
            'Table_name : ' || :table_name || char(10) ||
            'Action_commited : Add new column ' || :new_column_name || char(10) ||
            'status : sucess'); 

        return 'Failed to Add';
end;
$$;




call add_new_date_column('sales_data','new_order_date','order_date');


desc table sales_data;



create or replace procedure transform_age(table_name string,column_name string)
returns int
language sql
as
$$
declare
sql_stmt string;
total_rows int;
task_initiated datetime;
task_finished datetime;
to_get_user string;
begin

            task_initiated := current_timestamp();

            to_get_user := current_user();

            sql_stmt := 
            'update ' ||  table_name || 
            ' set  ' || column_name || ' = case
             when ' || column_name || ' > 90 then Null 
            when ' ||  column_name || ' < 0 then Null
             else '|| column_name || '
            end ';

            execute immediate sql_stmt;
            
            total_rows := sqlrowcount;

            task_finished := current_timestamp();


        insert into sales_details.bronze_layer.audit_table      
        (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
        values (:table_name,null,'Transform_Data',:total_rows,'Sucess',:task_initiated,:task_finished,null);

         call system$send_email('alert_user','subhashv9966@gmail.com','regarding_Transforming_data',
        'From_user : ' || :to_get_user || char(10) ||
        'Table_name : ' || :table_name || char(10) ||
        'Action_commited : Transform ' || :column_name || char(10) ||
        'count_of_transformed_rows : ' || :total_rows || char(10) ||
        'status : sucess'); 

        return 'Transformed Sucessfully ' || column_name;

exception
when other then

            task_finished := current_timestamp();
        insert into sales_details.bronze_layer.audit_table 
        (tablee_name,filee_name,action_type,source_count,status,start_time,end_time,error_message)
        values (:table_name,null,'Transform_Data',null,'Failed',:task_initiated,:task_finished,:sqlerrm);

        call system$send_email('alert_user','subhashv9966@gmail.com','regarding_Transforming_data',
        'From_user : ' || :to_get_user || char(10) ||
        'Table_name : ' || :table_name || char(10) ||
        'Action_commited : Transform ' || :column_name || char(10) ||
        ' status : Failed' || char(10) ||
        ' error message' || :sqlerrm);

        return 'Failed to Transform ' || column_name;

end;
$$;


call transform_age('sales_data','age');

select * from sales_details.silver_layer.sales_data;



