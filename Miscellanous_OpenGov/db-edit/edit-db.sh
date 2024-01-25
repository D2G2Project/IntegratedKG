#!/bin/bash

echo "$0: Start: $(date)"

echo "Viewing the PostgreSQL Client Version"

psql -Version

echo "Viewing the PostgreSQL Server Version"

export PGPASSWORD='citydb'
psql -h host.docker.internal -p 7777 -d sudtirol_db -U citydb -f edit-db.sql

echo "$0: End: $(date)"