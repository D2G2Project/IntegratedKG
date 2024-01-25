FROM ubuntu:latest
RUN apt-get update
RUN apt-get install postgresql-client -y
COPY edit-db.sh .
COPY edit-db.sql .
RUN chmod +x edit-db.sh
ENTRYPOINT ["/edit-db.sh"]