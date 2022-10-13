# usage

Start the bash duckdb CLI server with a command pointing it to the database file to be used:

		DDB_PATH=../myduck.db ./index.sh

You can then issue a request, for example:

		curl -s "localhost:8181/api/duckdb?q=select%20*%20from%20lineitem%20limit%201;"

