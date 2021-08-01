FROM tensorflow/serving

ENV MODEL_BASE_PATH /default

#RUN mkdir /models 
#RUN cd /models
RUN apt-get update && apt-get install -y curl
RUN mkdir /default
RUN cd /default 

COPY get-model.sh /usr/bin/get-model.sh
RUN chmod +x /usr/bin/get-model.sh
RUN sh /usr/bin/get-model.sh
#RUN curl ${TENSORFLOW_MODEL_URL} --output default.tar.gz

#RUN tar -zxvf default.tar.gz 
#RUN OLD_DIR_NAME="$(ls -I default.tar.gz)" 
#RUN mv ${MODEL_NAME} default

# COPY models/img_classifier /models/img_classifier



# Fix because base tf_serving_entrypoint.sh does not take $PORT env variable while $PORT is set by Heroku
# CMD is required to run on Heroku
COPY tf_serving_entrypoint.sh /usr/bin/tf_serving_entrypoint.sh
RUN chmod +x /usr/bin/tf_serving_entrypoint.sh
ENTRYPOINT []
CMD ["/usr/bin/tf_serving_entrypoint.sh"]