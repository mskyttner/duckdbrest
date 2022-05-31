ARG ver=v0.3.4

FROM debian

# if using alpine, add system library required for duckdb cli to run
# RUN apk update -qq && apk add --no-cache libstdc++

RUN apt update && apt install -y --no-install-recommends \
	wget \
	ca-certificates \
	unzip \
	procps

# sysdeps needed for bash-cli-api experiment
RUN apt install -y --no-install-recommends \
	socat \
	jq \
	gettext \
	perl \
	make \
	shared-mime-info 

RUN cpan File::MimeInfo::Magic

# install duckdb rest server and duckdb CLI
WORKDIR /usr/local/bin

ARG ver
ENV DUCKDB_VER $ver

RUN wget -O rest.zip "https://github.com/duckdb/duckdb/releases/download/$DUCKDB_VER/duckdb_rest-linux-amd64.zip" && \
	unzip rest.zip && \
	rm rest.zip && \
	chmod +x duckdb_rest_server

RUN wget -O cli.zip "https://github.com/duckdb/duckdb/releases/download/$DUCKDB_VER/duckdb_cli-linux-amd64.zip" && \
	unzip cli.zip && \
	rm cli.zip && \
	chmod +x duckdb

WORKDIR /data

# generate some example data
RUN duckdb myduck.db 'CALL dbgen(sf=0.1)'
RUN duckdb myduck.db 'select 42;'
RUN duckdb myduck.db 'install "httpfs";'
RUN duckdb myduck.db 'load "httpfs";'

# use a (sligthly) modified duckd rest server frontend
#RUN apt install -y git
#RUN git clone https://github.com/duckdb/duckdb.git
#RUN cp -r duckdb/tools/rest/frontend .

COPY frontend frontend

# gotty service for duckdb CLI
#ENV GOTTY_BINARY https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_386.tar.gz
ENV GOTTY_BINARY https://github.com/sorenisanerd/gotty/releases/download/latest/gotty_latest-1-gb63ea16_linux_amd64.tar.gz

RUN wget $GOTTY_BINARY -O gotty.tar.gz && \
    tar -xzf gotty.tar.gz -C /usr/local/bin/ && \
    rm gotty.tar.gz && \
    chmod +x /usr/local/bin/gotty

COPY .gotty /root/.gotty

# experimental bash CLI API (not for the faint of heart)
COPY bash-cli-api /bash-cli-api

# yet another experimental shell server
COPY sherver /sherver

VOLUME ["/data"]
EXPOSE 1294

CMD ["duckdb_rest_server", "--listen=0.0.0.0", "--port=1294", "--database=myduck.db", "--read_only", "--fetch_timeout=2", "--static=frontend", "--log=/proc/1/fd/1"]

# install minio client
RUN apt-get install -y --no-install-recommends \
	ca-certificates

RUN cd /usr/local/bin && \
  wget -q --show-progress https://dl.min.io/client/mc/release/linux-amd64/mc && \
  chmod +x mc

RUN apt-get install -y --no-install-recommends \
	fontconfig \
	fonts-hack && \
	fc-cache -f

# to start the experimental servers, use one of these commands in your docker-compose.yml file
#CMD sh -c "gotty --port ${PORT:-1294} --permit-write --reconnect duckdb -interactive myduck.db -readonly"
#CMD bash -c "cd /bash-cli-api && DDB_PATH=/data/myduck.db ./index.sh"
