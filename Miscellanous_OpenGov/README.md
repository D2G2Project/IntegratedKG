## D2G2 - Miscellaneous_OpenGov Integration Demo

This demo provides a pipeline to query via [Ontop](https://github.com/ontop/ontop) CityGML LOD0, OpenStreetMap (OSM), and South Tyrol geocatalogue and open government data.

### CityGML Specifications
**CityGML Ontology**: https://cui.unige.ch/isi/onto//citygml2.0.owl  
&nbsp;&nbsp;&nbsp;&nbsp;<ins>*NOTE*</ins>: Ontology was modified from original, adding further classes
on addresses (including xAL) and removing object properties with the same IRI as data properties.  
**CityGML Version**: 2.0  
**CityGML Level of Detail (LOD)**: 0
**Software for RDBMS schema**: [3DCityDB](https://www.3dcitydb.org/3dcitydb/)

### OSM Specifications
**OSM Ontology**: [LinkedGeoData](https://github.com/GeoKnow/LinkedGeoData/blob/develop/lgd-ontop-web/lgd.owl) ontology from the [LinkedGeoData project](http://linkedgeodata.org/)  
**Area**: Download North-East Italy data from [https://download.geofabrik.de/europe/italy/nord-est.html](geofabrik). Place it in the osm2pgsql folder.
**Date**: Latest data from geofabrik. NOTE: Download time too long for reasonably timed demo.
**Points of interest**: If more OSM entities of points of interest are needed e.g. parks etc. please modify the list of filtered classes in [osm-refined.lua](osm2pgsql/osm-refined.lua).

### Geographic area and data
**Region**: South Tyrol, Italy
**CityGML data source**: Miscellaneous
**Default SRID**: EPSG:25832

### Mapping specificatons: restrictions and limitations
**SRID**. All geometries are transformed to SRID EPSG:4326.
The rationale is that Yasgui visualization plugin used by Ontop can only operate on SRID 4326.  
In order to specify a different SRID, the second parameter of ST_SETSRID needs to be modified for each individual mapping.  
**Empty tables**. Only roof/construction data for LOD0 available for Italy.

## Instructions to run Ontop
### Execution
**Area**: Download North-East Italy data from [https://download.geofabrik.de/europe/italy/nord-est.html](geofabrik), specifically nord-est-latest.osm.pbf. Place it in the osm2pgsql folder.

Keep the ports 7777, 8082 free.

Execute:
```
docker-compose -f docker-compose.miscellaneous.yml up
```
It should take 5 minutes to set up.  
Open [localhost:8082](http://localhost:8082/) to see sample queries.