FROM tensorflow/serving

ENV MODEL_BASE_PATH /models
ENV MODEL_NAME img_classifier

COPY models/img_classifier /models/img_classifier

# Fix because base tf_serving_entrypoint.sh does not take $PORT env variable while $PORT is set by Heroku
# CMD is required to run on Heroku
COPY tf_serving_entrypoint.sh /usr/bin/tf_serving_entrypoint.sh
RUN chmod +x /usr/bin/tf_serving_entrypoint.sh
ENTRYPOINT []
CMD ["/usr/bin/tf_serving_entrypoint.sh"]