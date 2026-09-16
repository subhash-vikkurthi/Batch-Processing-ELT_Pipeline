create database sales_details;

create schema bronze_layer;

create or replace storage integration integrate_s3
type = external_stage
storage_provider = s3
enabled = true
storage_aws_role_arn = 'arn:aws:iam::YOUR-AWS-ID:role/ROLE-NAME'
storage_allowed_locations = ('s3://BUCKET-NAME/FOLDER-NAME/');


desc integration integrate_s3;

CREATE FILE FORMAT my_csv_format
  TYPE = CSV
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1;

CREATE STAGE my_s3_stage
  URL = 's3://BUCKET-NAME/FOLDER-NAME/'
  STORAGE_INTEGRATION = integrate_s3
  FILE_FORMAT = my_csv_format;


  list @my_s3_stage;

  create or replace notification integration alert_user
  type = email
  enabled = True
  allowed_recipients = ('your_mail@gmail.com')
  default_subject = 'Regarding_SalesData';

   --call system$send_email(alert_user,)


CALL SYSTEM$SEND_EMAIL('ALERT_USER','your_mail@gmail.com','REGARDING_LOADING_DATA',
'intergration is created sucesssfully');
