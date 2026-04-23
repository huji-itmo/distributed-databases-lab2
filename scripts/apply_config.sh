#!/usr/bin/env bash
source .env

if ! bash ./is_ready.sh; then
    echo "db id down";
    exit 1;
fi

source ./scripts/set_param.sh

PARAMS_FILE="./params.conf"

if [[ ! -f "$PARAMS_FILE" ]]; then
    echo "Error: $PARAMS_FILE not found!"
    exit 1
fi

while IFS='=' read -r key value; do
    eval "resolved=\"$value\""
    set_conf "$key" "$resolved"
done < "$PARAMS_FILE"
