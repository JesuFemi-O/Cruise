FROM tensorflow/serving


RUN apt-get update && apt-get install -y curl && apt-get install -y file

# Fix because base tf_serving_entrypoint.sh does not take $PORT env variable while $PORT is set by Heroku
COPY tf_serving_entrypoint.sh /usr/bin/tf_serving_entrypoint.sh
RUN chmod +x /usr/bin/tf_serving_entrypoint.sh

# CMD is required to run on Heroku
ENTRYPOINT []
CMD ["/usr/bin/tf_serving_entrypoint.sh"]
