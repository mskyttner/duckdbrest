#!/bin/bash

queryCLI() {
   add_response_header "Content-Type" "application/json"
   db=$DDB_PATH
   q=$(urldecode $1 | grep -oP "q=([^&]+)" | grep -oP "[^q=]+")
   results=$(duckdb $db --json "$q" | jq '.')
   send_response_ok_exit <<< $results
}

on_uri_match '^/api/duckdb[?]q=([^&].*?).*$' queryCLI "$REQUEST_URI"

