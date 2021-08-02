#!/bin/bash

mkdir /default
cd /default

curl $TENSORFLOW_MODEL_URL --output default.tar.gz
tar -zxvf default.tar.gz
mv $MODEL_FOLDER_NAME default

tensorflow_model_server --port=8500 --rest_api_port="${PORT}" --model_name="${MODEL_NAME}" --model_base_path="${MODEL_BASE_PATH}"/"${MODEL_NAME}" "$@"
