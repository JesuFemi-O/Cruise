#!/bin/bash

curl "${TENSORFLOW_MODEL_URL}" --output default.tar.gz
tar -zxvf default.tar.gz
mv "${MODEL_NAME}" default