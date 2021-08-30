#!/bin/bash

DEFAULT_FILE_NAME="default.tar.gz"

curl $TENSORFLOW_MODEL_URL --output $DEFAULT_FILE_NAME
OUTPUT=$(file --mime-type $DEFAULT_FILE_NAME)

if [[ $OUTPUT =~ "application/gzip" ]]
    then tar -zxvf $DEFAULT_FILE_NAME
else
    echo "File is of $OUTPUT format"
fi

tensorflow_model_server --port=8500 --rest_api_port="${PORT}" --model_config_file=/"${MODEL_BASE_PATH}"/"${MODEL_CONFIG_FILE}"  "$@"
