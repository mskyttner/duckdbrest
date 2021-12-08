FROM debian

# add system library required for duckdb cli to run
#RUN apk update -qq && apk add --no-cache libstdc++

RUN apt update && apt install -y wget unzip procps

WORKDIR /usr/local/bin

RUN wget -O rest.zip "https://github.com/duckdb/duckdb/releases/download/v0.3.1/duckdb_rest-linux-amd64.zip" && \
	unzip rest.zip && \
	rm rest.zip && \
	chmod +x duckdb_rest_server

RUN wget -O cli.zip "https://github.com/duckdb/duckdb/releases/download/v0.3.1/duckdb_cli-linux-amd64.zip" && \
	unzip cli.zip && \
	rm cli.zip && \
	chmod +x duckdb

WORKDIR /data

RUN duckdb myduck.db 'CALL dbgen(sf=0.1)'
RUN duckdb myduck.db 'select 42;'


#RUN apt install -y git
#RUN git clone https://github.com/duckdb/duckdb.git
#RUN cp -r duckdb/tools/rest/frontend .

COPY frontend frontend

ENV GOTTY_BINARY https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_386.tar.gz

RUN wget $GOTTY_BINARY -O gotty.tar.gz && \
    tar -xzf gotty.tar.gz -C /usr/local/bin/ && \
    rm gotty.tar.gz && \
    chmod +x /usr/local/bin/gotty

COPY .gotty /root/.gotty

RUN apt install -y socat jq

COPY bash-cli-api /bash-cli-api

VOLUME ["/data"]
EXPOSE 1294

CMD ["duckdb_rest_server", "--listen=0.0.0.0", "--port=1294", "--database=myduck.db", "--read_only", "--fetch_timeout=2", "--static=frontend", "--log=/proc/1/fd/1"]
#CMD sh -c "gotty --port ${PORT:-1294} --permit-write --reconnect duckdb -interactive myduck.db -readonly"
#CMD bash -c "cd /bash-cli-api && DDB_PATH=/data/myduck.db ./index.sh"
