FROM tensorflow/serving

ENV MODEL_BASE_PATH /default
ENV MODEL_NAME default

# COPY models/img_classifier /models/img_classifier
RUN apt-get update && apt-get install -y curl

# Fix because base tf_serving_entrypoint.sh does not take $PORT env variable while $PORT is set by Heroku
# CMD is required to run on Heroku
COPY tf_serving_entrypoint.sh /usr/bin/tf_serving_entrypoint.sh
RUN chmod +x /usr/bin/tf_serving_entrypoint.sh
ENTRYPOINT []
CMD ["/usr/bin/tf_serving_entrypoint.sh"]
