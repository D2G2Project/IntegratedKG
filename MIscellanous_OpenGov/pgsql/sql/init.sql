--Unnecessary if database name is specified in docker
--CREATE DATABASE sudtirol_db;

\connect sudtirol_db

CREATE EXTENSION postgis;
CREATE EXTENSION postgis_sfcgal;