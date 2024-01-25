FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y \
        osm2pgsql \
        postgresql-client-15 \
        osmctools \
        osmium-tool

# clean up
RUN apt-get clean \
        && rm -rf /var/lib/apt/lists/*

ADD ./osm-importer.sh /usr/local/bin/osm-importer.sh
ADD osm-refined.lua /user/local/bin/osm-refined.lua

RUN chmod +x /usr/local/bin/osm-importer.sh

RUN mkdir -p /osm/data
ADD nord-est-latest.osm.pbf /osm/data/nord-est-latest.osm.pbf

WORKDIR /osm