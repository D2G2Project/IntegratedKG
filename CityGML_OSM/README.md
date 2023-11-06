## D2G2 - CityGML-OSM Integration Demo

This demo provides a pipeline to query via [Ontop](https://github.com/ontop/ontop) CityGML and OpenStreetMap (OSM) data.

### CityGML Specifications
**CityGML Ontology**: https://cui.unige.ch/isi/onto//citygml2.0.owl  
&nbsp;&nbsp;&nbsp;&nbsp;<ins>*NOTE*</ins>: Ontology was modified from original, adding further classes
on addresses (including xAL) and removing object properties with the same IRI as data properties.  
**CityGML Version**: 2.0  
**Software for RDBMS schema**: [3DCityDB](https://www.3dcitydb.org/3dcitydb/)

### OSM Specifications
**OSM Ontology**: [LinkedGeoData](https://github.com/GeoKnow/LinkedGeoData/blob/develop/lgd-ontop-web/lgd.owl) ontology from the [LinkedGeoData project](http://linkedgeodata.org/)  
**Area**: Modify the parameter REGION depending on the desired OSM region as per [geofabrik](http://download.geofabrik.de/). Currently OSM script is importing the region of [Oberbayern](http://download.geofabrik.de/europe/germany/bayern/oberbayern.html) in Bavaria, Germany.
If further refinement is needed modify the coordinates of the sub-area within the region as needed in [osm-importer.sh](osm2pgsql/osm-importer.sh)  
**Date**: Latest data from geofabrik  
**Points of interest**: If more OSM entities of points of interest are needed e.g. parks etc. please modify the list of filtered classes in [osm-refined.lua](osm2pgsql/osm-refined.lua).

### Geographic area and data
**Region**: Munich city center, Bavaria  
**CityGML data source**: [Bavarian OPENDATA portal](https://geodaten.bayern.de/opengeodata/)  
**Default SRID**: EPSG:25832  
**RoofType codes data source**: ATKIS/ALKIS codes in [CityGMLWiki](EPSG:25832)  
**Addresses**: xAL - eXtensible Address Language by OASIS

### Mapping specificatons: restrictions and limitations
**SRID**. All geometries are transformed to SRID EPSG:4326.
The rationale is that Yasgui visualization plugin used by Ontop can only operate on SRID 4326.  
In order to specify a different SRID, the second parameter of ST_SETSRID needs to be modified for each individual mapping.  
**Empty tables**. CityGML data sources for Bavaria mostly cover buildings.
Hence the mappings for concepts such as WaterBody or Vegetation were constructed on empty tables,
and cannot be considered exhaustively or robustly tested.
**xAL address extraction**. For different regions (i.e. outside Bavaria) the extraction of the xAL properties might need to be modified in [db edit SQL file](db-edit/edit-citydb-bavaria.sql).
Different countries seem to encode different address information and hierarchies, which seems to largely depend on
the respective national conventions.

### CityGML-OSM Linkage
#### Reification
Reification is used to express linkages OSM and CityGML instances. An example is provided below for matches, a similar one can be constructed for adjacency.

```
 d2g2:Association_CityGML_OSM       rdf:type              owl:Class .
 d2g2:association_CityGML_OSM1      rdf:type              d2g2:Association_CityGML_OSM .
 d2g2:association_CityGML_OSM1      d2g2:matchCityGML     d2g2:cityobject1 .
 d2g2:association_CityGML_OSM1      d2g2:matchOSM         lgdo:osm_id1 .
```

#### Linkage data
If a different file is required for the linkage please modify the files located in the [linkage data folder](linkage_citygml_osm/data.zip).

## Instructions to run Ontop
### Execution
Keep the ports 7778, 8082 free.

Execute:
```
docker-compose -f docker-compose.linkage.yml up
```
It should take 5 minutes to set up.  
Open [localhost:8082](http://localhost:8082/) to see sample queries.

### Mofidying the demo with different data
#### 3D City Importer Exporter
Place all the gml files you want to use in the citygml-data folder. If more files are desired vs. the demo but still for
the region of Bavaria; navigate to the citygml-data folder, modify the range of [get-munich-citygml.sh](citygml-data/get-munich-citygml.sh) and run:
```
bash get-munich-citygml.sh
```
It downloads files corresponding to the range provided for [EPSG:25832](https://epsg.io/25832) from the [Bavarian geoportal](https://geoportal.bayern.de/bayernatlas/?lang=de&topic=ba&bgLayer=atkis&catalogNodes=11&layers=WMS%7C%7COpendata_Auswahl_LoD2%7C%7Chttps:%2F%2Fgeoservices.bayern.de%2Fwms%2Fv1%2Fopendatagrid%7C%7Clod2%7C%7C1.1.1).

## Instructions to run Apache Jena-Fuseki with triples materialized via Ontop
Keep the ports 7778, 8082, 3030 free.

The same pipeline as above is used with the exception being that
ontop materialize is utilized instead of ontop endpoint. A file named
```materialized-triples.ttl``` is generated via Ontop.

### Run Apache Jena-Fuseki without the GeoSPARQL extension

Execute:
```
docker-compose -f docker-compose.jena-fuseki.yml up
```

&nbsp;&nbsp;&nbsp;&nbsp;<ins>*NOTE/LIMITATION*</ins> The GeoSPARQL extension of Jena-Fuseki does not currently support
polyhedral surfaces as geometry datatypes. Therefore this demo does not make use the extension.

#### Explore results
Open [localhost:3030](http://localhost:3030/). When prompted for username and password
provide:
- username: admin
- password: admin
  Manually copy and execute sample queries such as those
  from [citygml2.0.portal.toml](vkg/citygml2.0.portal.toml). The Jena UI of version 4.8.0 does not currently
  support predefined queries.