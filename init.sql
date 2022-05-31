load '/extensions/httpfs.duckdb_extension';
set s3_endpoint='minio:9000';
set s3_access_key_id='minioadmin';
set s3_secret_access_key='minioadmin';
set s3_use_ssl=false;
set s3_region='';
.timer on
select count(*) from 's3://demo/*.parquet';
.shell more init.sql
