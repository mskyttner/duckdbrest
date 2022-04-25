install 'httpfs';
load 'httpfs';
set s3_endpoint='http://minio:9000';
set s3_access_key_id='minioadmin';
set s3_secret_access_key='minioadmin';
.timer on
select count(*) from 's3://demo/*.parquet';
.shell more init.sql
