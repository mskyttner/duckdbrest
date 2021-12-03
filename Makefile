#! make

build:
	docker build -t duckdbrest .

dbgen:
	duckdb myduck.db 'CALL dbgen(sf=0.1)'
	duckdb myduck.db 'select 42'

up:
	docker-compose up -d
