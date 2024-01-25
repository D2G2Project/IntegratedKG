FROM ghcr.io/osgeo/gdal:ubuntu-small-latest

ENV PG_CONN='host=host.docker.internal user=citydb dbname=sudtirol_db password=citydb port=7777'
ENV WFS_CART_URL=https://geoservices3.civis.bz.it/geoserver/gvcc-Cartography/ows?service=wfs&version=2.0.0&request=getCapabilities

COPY script.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/script.sh
CMD ["script.sh"]