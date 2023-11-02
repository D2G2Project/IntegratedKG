
-- Due to the geofabrik file downloaded at a different date vs. QGIS shapefiles for OSM
-- Any inconsistent osm_id-s need to be removed (ca.300 as of july 2023)
DELETE FROM citydb."citygml_osm_association"
WHERE associated_osmid NOT IN (
    SELECT entities.osm_id
    FROM public."entities");

-- Respective FK can now be added
ALTER TABLE ONLY citydb."citygml_osm_association"
    ADD CONSTRAINT fk_association_osmid FOREIGN KEY ("associated_osmid") REFERENCES public."entities" ("osm_id");


-- Update citygml-osm linkage table
ALTER TABLE citygml_osm_association DROP COLUMN id;

INSERT INTO citygml_osm_association (associated_citygmlid, associated_osmid, association_type, osm_type)
SELECT DISTINCT associated_citygmlid, points.osm_id AS associated_osm_id, association_type, 'n' AS osm_type
FROM (
        SELECT osm_id, geom FROM public.entities
        WHERE osm_type='N')
    AS points
JOIN (  SELECT associated_citygmlid, association_type, geom FROM
        public.entities
        JOIN citygml_osm_association coa on entities.osm_id = coa.associated_osmid
        WHERE entities.osm_type != 'N')
    AS polygons
ON ST_Contains(polygons.geom, points.geom)
WHERE ST_GeometryType(points.geom) = 'ST_Point';

ALTER TABLE citygml_osm_association ADD id SERIAL PRIMARY KEY;