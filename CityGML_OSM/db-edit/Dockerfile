FROM ubuntu:latest
RUN apt-get update
RUN apt-get install postgresql-client -y
COPY edit-citydb-bavaria.sql .
COPY edit-citydb.sh .
RUN chmod +x edit-citydb.sh
ENTRYPOINT ["/edit-citydb.sh"]