import psycopg2
import requests

# Function to fetch data from the ODH API
def fetch_data(api_url):
    response = requests.get(api_url)
    if response.status_code == 200:
        return response.json()
    else:
        print("API request failed with status code:", response.status_code)
        exit(1)

# Function to insert data into PostgreSQL
def insert_data(conn, insert_query, data_list, value_mappings):
    cursor = conn.cursor()
    for item in data_list["data"]:
        values = [item.get(value, None) for value in value_mappings]
        cursor.execute(insert_query, values)
    conn.commit()
    cursor.close()

# Connection details
db_config = {
    "host": "host.docker.internal",
    "database": "sudtirol_db",
    "user": "citydb",
    "password": "citydb",
    "port": 7777
}

# Table 1 - Temperature measurements
api_url = "https://mobility.api.opendatahub.com/v2/flat%2Cnode/MeteoStation/%2A/2023-10-01T00%3A00%3A00/2023-10-31T23%3A59%3A59?limit=30000&offset=0&select=tunit%2Cmvalue%2Cscode%2Cmvalidtime&where=and%28or%28tname.eq.%22air-temperature%22%2Ctname.eq.%22Air_Temperature%22%29%2Cmvalidtime.neq.null%29&shownull=false&distinct=true&timezone=UTC"

json_data = fetch_data(api_url)
data_list = json_data
insert_query = f"INSERT INTO TEMPERATURE_MEASUREMENTS (station_code, timestamp_val, temperature, unit) VALUES (%s, %s, %s, %s)"
value_mappings = ["scode", "mvalidtime", "mvalue", "tunit"]

conn = psycopg2.connect(**db_config)
insert_data(conn, insert_query, data_list, value_mappings)
conn.close()


# Table 2 - Max/Min Temperature and Precipitation
api_url = "https://mobility.api.opendatahub.com/v2/flat%2Cnode/MeteoStation/%2A/latest?limit=-1&offset=0&where=or%28tname.eq.%22air-temperature-min%22%2Ctname.eq.%22air-temperature-max%22%2Ctname.eq.%22precipitation%22%29&shownull=false&distinct=true&timezone=UTC"

json_data = fetch_data(api_url)
data_list = json_data
insert_query = f"INSERT INTO METEO_MEASUREMENTS (station_code, timestamp_val, temperature, unit, datatype) VALUES (%s, %s, %s, %s, %s)"
value_mappings = ["scode", "mvalidtime", "mvalue", "tunit", "tname"]

conn = psycopg2.connect(**db_config)
insert_data(conn, insert_query, data_list, value_mappings)
conn.close()



# Table 3 - MeteoStations and Coordinates
api_url = "https://mobility.api.opendatahub.com/v2/flat%2Cnode/MeteoStation?limit=-1&offset=0&select=sname%2Csmetadata.name_de%2Csmetadata.name_en%2Csmetadata.name_i%2Cscode%2Cscoordinate&shownull=false&distinct=true"

json_data = fetch_data(api_url)
data_list = json_data
insert_query = f"INSERT INTO METEO_STATIONS (station_code, name, name_de, name_it, name_en, latitude, longitude) VALUES (%s, %s, %s, %s, %s, %s, %s)"
value_mappings = ["scode", "sname", "smetadata.name_de", "smetadata.name_it", "smetadata.name_en", "scoordinate"]

conn = psycopg2.connect(**db_config)
cursor = conn.cursor()
for item in data_list["data"]:
    scode = item.get("scode", None)
    name = item.get("sname", None)
    name_de = item.get("smetadata.name_de", None)
    name_it = item.get("smetadata.name_it", None)
    name_en = item.get("smetadata.name_en", None)
    lat_value_1 = item.get("scoordinate",None)
    lat_value_f = None if lat_value_1 is None else lat_value_1.get("x")
    lng_value_1 = item.get("field3", None)
    lng_value_f = None if lat_value_1 is None else lat_value_1.get("y")


    cursor.execute(insert_query, (scode, name, name_de, name_it, name_en, lat_value_f, lng_value_f))

conn.commit()  # Save the changes
conn.close()  # Close the database connection
