#!/usr/bin/env bash

send() {
        printf '%s\r\n' "$*";
 }

DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")
declare -a RESPONSE_HEADERS=(
	"Date: $DATE"
	"Expires: $DATE"
	"Server: Bash REST Server"
)

add_response_header() {
	RESPONSE_HEADERS+=("$1: $2")
}

declare -a HTTP_RESPONSE=(
	[200]="OK"
	[400]="Bad Request"
	[403]="Forbidden"
	[404]="Not Found"
	[405]="Method Not Allowed"
	[500]="Internal Server Error"
)

send_response() {
	local code=$1
   	send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
   	for i in "${RESPONSE_HEADERS[@]}"; do
   		send "$i"
   	done
   	send
   	while read -r line; do
   		send "$line"
   	done
}

send_response_ok_exit() { send_response 200; exit 0; }

fail_with() {
	send_response "$1" <<< "$1 ${HTTP_RESPONSE[$1]}"
	exit 1
}

on_uri_match() {
	local regex=$1
	shift
	[[ $REQUEST_URI =~ $regex ]] && "$@" "${BASH_REMATCH[@]}"
}

processBody()
{
	if [ $length -gt 0 ] ; then
		echo "About to read body" >&2
		REQUEST_BODY=""
		declare -i bodylen=0

		while read -r body; do
			bodyParsed=${body%%$'\r'}
			echo $bodyParsed >&2
			REQUEST_BODY=("$REQUEST_BODY$body")
			((bodylen=$bodylen+${#body}+2))
			echo $bodylen >&2
			[ $length -eq $bodylen ] && break
		done
	fi
}

processHeaders()
{
	read -r request || fail_with 400

	request=${request%%$'\r'}
	echo $request >&2
	read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION <<<$request

	[ -n "$REQUEST_METHOD" ] && \
	[ -n "$REQUEST_URI" ] && \
	[ -n "$REQUEST_HTTP_VERSION" ] \
	   	|| fail_with 400

	[ "$REQUEST_METHOD" = "GET" ] || [ "$REQUEST_METHOD" = "POST" ] || fail_with 405

	declare -a REQUEST_HEADERS

	while read -r header; do
		header=${header%%$'\r'}
		[ -z "$header" ] && break
		echo $header >&2
		REQUEST_HEADERS+=("$header")
	done
}

# Following regex is based on https://www.rfc-editor.org/rfc/rfc3986#appendix-B with
# additional sub-expressions to split authority into userinfo, host and port
readonly URI_REGEX='^(([^:/?#]+):)?(//((([^:/?#]+)@)?([^:/?#]+)(:([0-9]+))?))?(/([^?#]*))(\?([^#]*))?(#(.*))?'
#                    ↑↑            ↑  ↑↑↑            ↑         ↑ ↑            ↑ ↑        ↑  ↑        ↑ ↑
#                    |2 scheme     |  ||6 userinfo   7 host    | 9 port       | 11 rpath |  13 query | 15 fragment
#                    1 scheme:     |  |5 userinfo@             8 :…           10 path    12 ?…       14 #…
#                                  |  4 authority
#                                  3 //…

parse_scheme () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[2]}"
}

parse_authority () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[4]}"
}

parse_user () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[6]}"
}

parse_host () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[7]}"
}

parse_port () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[9]}"
}

parse_path () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[10]}"
}

parse_rpath () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[11]}"
}

parse_query () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[13]}"
}

parse_fragment () {
    [[ "$@" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[15]}"
}

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
