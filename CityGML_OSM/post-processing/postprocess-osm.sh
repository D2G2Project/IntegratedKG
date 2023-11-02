#!/bin/bash

echo "$0: Start: $(date)"

echo "Viewing the PostgreSQL Client Version"

psql -Version

echo "Viewing the PostgreSQL Server Version"

export PGPASSWORD='citydb'
psql -h host.docker.internal -p 7778 -d citydb -U citydb -f postprocess-osm.sql

echo "$0: End: $(date)"