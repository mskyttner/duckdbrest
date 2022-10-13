#! make

dl:
	git clone git@github.com:remileduc/sherver.git

dl2: scratch
	git clone https://github.com/skeeto/scratch.git

csvquote:
	#cd scratch/csvquote && make CFLAGS=-O3 bench
	cd scratch/csvquote && ./csvdump | ./csvquote | head -50 > ../../example.csv
	#cd scratch/csvquote && cat ../../example.csv | ./csvquote > ../../example-quoted.csv

#scanners:
#	git clone git@github.com:duckdblabs/postgres_scanner.git
#	git clone git@github.com:duckdblabs/sqlite_scanner.git

official:
	docker build -t duckdbrest:v0.5.1 --build-arg ver=v0.5.1 .

build-master:
	#docker build -t duckdbrest .
	docker build --progress=plain -t duckdbrest -f Dockerfile.main .

testapi:
	curl -s "localhost:8181/api/duckdb?q=select%20*%20from%20lineitem%20limit%201;"

dbgen:
	duckdb myduck.db 'CALL dbgen(sf=0.1)'
	duckdb myduck.db 'select 42'

up:
	docker-compose up -d
