--load '/extensions/httpfs.duckdb_extension';
load 'httpfs';
load 'postgres_scanner';
load 'sqlite_scanner';

set s3_endpoint=$S3_ENDPOINT;
set s3_access_key_id=$S3_USER;
set s3_secret_access_key=$S3_PASS;
set s3_use_ssl=$S3_USE_SSL;
set s3_region=$S3_REGION;
set s3_url_style=$S3_URL_STYLE;

.system echo "Local duckdb data available:"
PRAGMA show_tables;

.system echo "Remote S3 connection data available:"
.system mc tree -f s3
.system echo "\nQuery example:"
.system echo "\nselect count(*) from 's3://$S3_BUCKET/*.parquet';\n"

PRAGMA enable_progress_bar;
.system NCPU=$(nproc --all) && echo "To use more threads, use:\nPRAGMA threads=$((NCPU - 1));\n"

