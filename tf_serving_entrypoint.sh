#!/bin/bash

curl $TENSORFLOW_MODEL_URL --output default.tar.gz
tar -zxvf default.tar.gz

tensorflow_model_server --port=8500 --rest_api_port="${PORT}" --model_config_file=/"${MODEL_BASE_PATH}"/"${MODEL_CONFIG_FILE}"  "$@"