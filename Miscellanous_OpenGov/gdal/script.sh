#!/bin/bash

PG_CONN='"host=host.docker.internal user=citydb dbname=sudtirol_db password=citydb port=7777"'
#WFS_CART_URL_1=https://geoservices1.civis.bz.it/geoserver/p_bz-AdministrativeUnits/ows?service=wfs&version=2.0.0&request=getCapabilities
#WFS_CART_URL_3=https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=wfs&version=2.0.0&request=getCapabilities
WFS_CART_URL=https://geoservicesservice_no.civis.bz.it/geoserver/feature_name/ows?service=wfs

# Define the maximum number of retries
max_retries=3

# Define list of layers
# Order is : 1) Geoservices number 2) Desired table name 3) feature 4) layer:feature
table_layer_pair=(
  "1 municipalities p_bz-AdministrativeUnits p_bz-AdministrativeUnits:Municipalities"
  "3 construction_01k gvcc-Cartography gvcc-Cartography:ConstructionAreas-01k"
  "8 road_area p_bz-Inspire p_bz-Inspire:TN.RoadTransportNetwork.RoadArea"
  "8 road_link p_bz-Inspire p_bz-Inspire:TN.RoadTransportNetwork.RoadLink"
  )
    # Data from source below does not match with mobility API station codes
    #  "2 meteo_stations pczs-Meteorology pczs-Meteorology:WeatherStations"
    # Little value added
    # "3 roofarea_01k gvcc-Cartography gvcc-Cartography:RoofAreasScale-01k"

for pair in "${table_layer_pair[@]}"; do
  max_retries=3
  echo "Processing: $pair"
  IFS=' ' read -ra parts <<< "$pair"
  service_no="${parts[0]}"
  table="${parts[1]}"
  feature="${parts[2]}"
  layer="${parts[3]}"

  # Replace geoservice number
  WFS_CART_URL_t1=${WFS_CART_URL/service_no/$service_no}
  # Replace feature name
  WFS_CART_URL_final=${WFS_CART_URL_t1/feature_name/$feature}

  # Run script
  for ((retry = 1; retry <= max_retries; retry++)); do
      echo "Attempt $retry of $max_retries"
      ogr2ogr -f "PostgreSQL" PG:"host=host.docker.internal user=citydb dbname=sudtirol_db password=citydb port=7777" -nln $table -a_srs EPSG:25832 WFS:$WFS_CART_URL_final $layer
      if [ $? -eq 0 ]; then
            echo "Success: $pair"
            break
          elif [ $retry -eq $max_retries ]; then
            echo "Max retries reached for: $pair"
            exit 1
          else
            echo "Attempt $retry failed for: $pair"
            sleep 5
          fi
        done
done
