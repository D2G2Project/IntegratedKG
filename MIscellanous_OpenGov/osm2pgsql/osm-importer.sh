#!/bin/bash
# Updated author: Ariel Kadouri
# Original author: Rex Tsai <rex.cc.tsai@gmail.com> https://github.com/OsmHackTW/osm2pgsql-docker

export PGPASSWORD=$PG_ENV_POSTGRES_PASSWORD
echo DATADIR=${DATADIR:="/osm/data"}
mkdir -p DATADIR
echo PBF=${PBF:=$DATADIR/$(echo $REGION | grep -o '[^/]*$')-latest.osm.pbf}
#HOST=download.geofabrik.de

# For this demo we do not wish to apply any updates
#    echo "Database not ready, need to intialize."
#    if [[ -f "$PBF" ]]; then
#        echo "Using local file at $PBF"
#    else
#        echo "$PBF File not found, downloading..."
#        mkdir -p DATADIR
#        wget -O "${PBF}" http://${HOST}/${REGION}-latest.osm.pbf
#        echo "Download done"
#    fi
#
#    osmium fileinfo $PBF

  # Bounding box of osmium tool seems to require EPSG:4326 data
  # This specific box only deals with 690_5334.gml
  # (692065.86 5336041.33) to (689943.8 5333949.88) for central Munich
  # which becomes (11°34'56.221"  48°8'54.948") to (11°33'10.259"  48°7'49.57")
    osmium extract -b 12.51,47.14,10.29,46.18 $PBF -o /osm/data/extract.osm.pbf
    PBFX=/osm/data/extract.osm.pbf

    psql --no-password \
        -h $PG_PORT_5432_TCP_ADDR -p $PG_PORT_5432_TCP_PORT \
        -U $PG_ENV_POSTGRES_USER $PG_ENV_POSTGRES_DB


    osm2pgsql -v \
        -k \
        --create \
        --slim \
        --cache 4000 \
        --extra-attributes \
        --output=flex \
        --style /user/local/bin/osm-refined.lua \
        --host $PG_PORT_5432_TCP_ADDR \
        --database $PG_ENV_POSTGRES_DB \
        --username $PG_ENV_POSTGRES_USER \
        --port $PG_PORT_5432_TCP_PORT \
        $PBFX
#fi