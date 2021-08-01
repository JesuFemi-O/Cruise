#!/bin/bash

tensorflow_model_server --port=8500 --rest_api_port="${PORT}" --model_name="${MODEL_NAME}" --model_base_path="${MODEL_BASE_PATH}"/"${MODEL_NAME}" "$@"
