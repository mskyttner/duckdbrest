# duckdbrest

Example with containerized duckdb (see docker-compose.yml):

- gotty web interface exposing duckdb CLI against TCP-H 0.1 data and bundled minio client
- bash-cli-api - a toy example based on a slightly modified variant of https://github.com/yurikoex/bash-rest-server, uses bash along with socat, jq and grep to query the data
- minio server w some parquet files
- nginx web server exposing /gotty and /minio services

## usage

Build and start using Makefile (see docker-compose.yml).

Once running, open

	- http://localhost:8080 (duckdb CLI exposed as web tty) or http://localhost/gotty

Or if brave try the toy example bash api server:

	curl -s "http://localhost:8181/api/duckdb?q=select%20*%20from%20lineitem%20limit%202;"

	# or without urlencoding the sql query and using firefox
	firefox "http://localhost:8181/api/duckdb?q=select * from lineitem limit 10;"

## screenshots

The duckdb_rest_server with TCP-H 0.1 has recently been discontinued:

![](screenshot-1.png)

The "gotty" web interface to duckdb in this container:

![](screenshot-2.png)

The bash-api-cli toy example in the same container:

![](screenshot-3.png)
