#! make

dl:
	git clone git@github.com:remileduc/sherver.git

dl2: scratch
	git clone https://github.com/skeeto/scratch.git

csvquote:
	#cd scratch/csvquote && make CFLAGS=-O3 bench
	cd scratch/csvquote && ./csvdump | ./csvquote | head -50 > ../../example.csv
	#cd scratch/csvquote && cat ../../example.csv | ./csvquote > ../../example-quoted.csv

build:
	docker build -t duckdbrest .

dbgen:
	duckdb myduck.db 'CALL dbgen(sf=0.1)'
	duckdb myduck.db 'select 42'

up:
	docker-compose up -d
