FROM ubuntu:latest
RUN apt-get update
RUN apt-get install postgresql-client -y
COPY postprocess-osm.sql .
COPY postprocess-osm.sh .
RUN chmod +x postprocess-osm.sh
ENTRYPOINT ["/postprocess-osm.sh"]