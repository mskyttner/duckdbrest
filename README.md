# duckdbrest

Example with containerized duckdb (see docker-compose.yml):

- duckdb_rest_server - which powers the demo at https://duckdb.org
- gotty web interface for duckdb CLI against TCP-H 0.1 data
- bash-cli-api - a toy example based on a slightly modified variant of https://github.com/yurikoex/bash-rest-server, uses bash along with socat, jq and grep to query the data

## usage

Build and start using Makefile (see docker-compose.yml).

Once running, open

	- http://localhost:1294 (duckdb_rest_server)
	- http://localhost:8080 (duckdb CLI from web tty)

Or if brave try the toy example bash api server:

	curl -s http://localhost:8181/api/duckdb?q=select%20*%20from%20lineitem%20limit%202;

	firefox "http://localhost:8181/api/duckdb?q=select from lineitem limit 10;"

## screenshots

![](screenshot-1.png)

![](screenshot-2.png)
