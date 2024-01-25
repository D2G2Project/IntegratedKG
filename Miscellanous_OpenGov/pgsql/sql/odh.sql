CREATE TABLE METEO_MEASUREMENTS
(
    id SERIAL PRIMARY KEY,
    station_code TEXT NOT NULL,
    timestamp_val TIMESTAMP NOT NULL,
    temperature DOUBLE PRECISION,
    unit TEXT,
    datatype TEXT
);

CREATE TABLE TEMPERATURE_MEASUREMENTS
(
    id SERIAL PRIMARY KEY,
    station_code TEXT NOT NULL,
    timestamp_val TIMESTAMP NOT NULL,
    temperature DOUBLE PRECISION,
    unit TEXT
);

CREATE TABLE METEO_STATIONS
(
    station_code TEXT NOT NULL PRIMARY KEY,
    name TEXT,
    name_de TEXT,
    name_it TEXT,
    name_en TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
);
