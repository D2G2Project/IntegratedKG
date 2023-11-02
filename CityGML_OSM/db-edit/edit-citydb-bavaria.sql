-- Depending on the country, the xal_source XML tree is different and the paths and data that can be extracted varies

ALTER TABLE citydb.address
    ADD COLUMN xal_locality_name VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_locality_type VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_thoroughfare_name VARCHAR(256);

ALTER TABLE citydb.address
    ADD COLUMN xal_thoroughfare_type VARCHAR(256);

UPDATE citydb.address
SET xal_locality_name = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:LocalityName/text()', xal_source::xml,
                               ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_locality_type = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/@Type', xal_source::xml,
                               ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_thoroughfare_name = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:Thoroughfare/xAL:ThoroughfareName/text()', xal_source::xml,
                                   ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

UPDATE citydb.address
SET xal_thoroughfare_type = (xpath('/xAL:AddressDetails/xAL:Country/xAL:Locality/xAL:Thoroughfare/@Type', xal_source::xml,
                                   ARRAY[ARRAY['xAL', 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0']]))[1] ;

--Due to sqlalchemy limitations, adding foreign keys is not possible, hence we do it here
CREATE TABLE citydb."citygml_osm_association" (
    "id" BIGINT NOT NULL PRIMARY KEY,
    "associated_citygmlid" TEXT NOT NULL,
    "associated_osmid" TEXT NOT NULL,
    "association_type" TEXT NOT NULL,
    "osm_type" TEXT NOT NULL
);

-- Based on their discussion https://github.com/3dcitydb/3dcitydb/issues/100 the UNIQUE constraint on the gmlid
-- column has been dropped. However, since for our use cases we will not perform any intertemporal analysis of CityGML
-- data, we can add this constraint aiming to improve Ontop's performance.
ALTER TABLE citydb.cityobject ADD CONSTRAINT unique_gmlid UNIQUE (gmlid);

-- PostgreSQL requires "cityobject"."gmlid" to be declared as UNIQUE before adding foreign key.
ALTER TABLE ONLY citydb."citygml_osm_association"
    ADD CONSTRAINT fk_association_gmlid FOREIGN KEY ("associated_citygmlid") REFERENCES citydb."cityobject" ("gmlid");
-- TODO: osm_id is NOT UNIQUE.
-- ALTER TABLE ONLY citydb."citygml_osm_association"
--     ADD CONSTRAINT fk_association_osmid FOREIGN KEY ("associated_osmid") REFERENCES public."classes" ("osm_id");

-- Add roof types
-- Based on https://www.citygmlwiki.org/images/f/fd/RoofTypeTypeAdV-trans.xml
CREATE TABLE citydb.roof_codelist (
    "name" TEXT NOT NULL PRIMARY KEY,
    "gmlid" TEXT NOT NULL,
    "description_de" TEXT NOT NULL,
    "description_en" TEXT NOT NULL
);

INSERT INTO citydb.roof_codelist VALUES
(1000, 'AdVid357', 'Flachdach', 'flat roof'),
(2100, 'AdVid358', 'Pultdach', 'pent roof'),
(2200, 'AdVid359', 'Versetztes Pultdach', 'offset pent roof'),
(3100, 'AdVid360', 'Satteldach', 'gabled roof'),
(3200, 'AdVid361', 'Walmdach', 'hipped roof'),
(3300, 'AdVid362', 'Krüppelwalmdach', 'half hipped roof'),
(3400, 'AdVid363', 'Mansardendach', 'mansard roof'),
(3500, 'AdVid364', 'Zeltdach', 'tented roof'),
(3600, 'AdVid365', 'Kegeldach', 'cone roof'),
(3700, 'AdVid366', 'Kuppeldach', 'copula roof'),
(3800, 'AdVid367', 'Sheddach', 'sawtooth roof'),
(3900, 'AdVid368', 'Bogendach', 'arch roof'),
(4000, 'AdVid369', 'Turmdach', 'pyramidal broach roof'),
(5000, 'AdVid370', 'Mischform', 'combination of roof forms'),
(9999, 'AdVid371', 'Sonstiges', 'other');

ALTER TABLE ONLY citydb.building
    ADD CONSTRAINT fk_roof_type FOREIGN KEY ("roof_type") REFERENCES citydb.roof_codelist ("name");


-- Add transformed geometry to WGS84 directly for surfaces in citydb table
-- ALTER TABLE citydb.surface_geometry
--     ADD COLUMN geometry_wgs84 GEOMETRY;

-- UPDATE citydb.surface_geometry
--     SET geometry_wgs84 = ST_TRANSFORM("geometry", 4326);

-- Add more spatial indexes for GEOGRAPHY datatype
CREATE INDEX surfacegeom_geog ON citydb.surface_geometry USING gist(CAST(ST_TRANSFORM("geometry",4326) AS GEOGRAPHY));
-- CREATE INDEX surfacegeom_geog2 ON citydb.surface_geometry USING gist(CAST("geometry_wgs84" AS GEOGRAPHY));
CREATE INDEX classes_geog ON public.entities USING gist(CAST(geom AS geography));


-- Add https://postgis.net/docs/reference.html#reference_sfcgal support for SCFGAL
CREATE extension postgis_sfcgal;

-- Add table with LGD classes and class id-s
ALTER TABLE public.classes DROP COLUMN id;
INSERT INTO public.classes VALUES
                               ('AlcoholShop'),
                               ('AntiquesShop'),
                               ('ApartmentBuilding'),
                               ('ApplianceShop'),
                               ('ArtShop'),
                               ('ArtsCentre'),
                               ('ArtShop'),
                               ('Artwork'),
                               ('ATM'),
                               ('Attraction'),
                               ('BabyGoods'),
                               ('BagsShop'),
                               ('Bakery'),
                               ('Bank'),
                               ('Bar'),
                               ('BathroomFurnishing'),
                               ('BeautyShop'),
                               ('BedShop'),
                               ('Bench'),
                               ('BicycleParking'),
                               ('BicycleRental'),
                               ('BicycleShop'),
                               ('Biergarten'),
                               ('BookmakerShop'),
                               ('BooksShop'),
                               ('Boutique'),
                               ('Bridge'),
                               ('Brownfield'),
                               ('Building'),
                               ('BuildingChapel'),
                               ('BuildingChurch'),
                               ('BuildingCommercial'),
                               ('BuildingDormitory'),
                               ('BuildingGarage'),
                               ('BuildingHospital'),
                               ('BuildingKiosk'),
                               ('BuildingOffice'),
                               ('BuildingResidential'),
                               ('BuildingRetail'),
                               ('BuildingSchool'),
                               ('BureauDeChange'),
                               ('BusStop'),
                               ('Butcher'),
                               ('Cafe'),
                               ('CameraShop'),
                               ('Carpet'),
                               ('CarRental'),
                               ('CarSharing'),
                               ('CarShop'),
                               ('CarWash'),
                               ('Casino'),
                               ('Cemetery'),
                               ('CharityShop'),
                               ('Cheese'),
                               ('Chemist'),
                               ('Childcare'),
                               ('Chocolate'),
                               ('Cinema'),
                               ('City'),
                               ('Clinic'),
                               ('Clock'),
                               ('Clothes'),
                               ('CoffeeShop'),
                               ('Collapsed'),
                               ('College'),
                               ('CommercialLanduse'),
                               ('CommunityCentre'),
                               ('Computer'),
                               ('Confectionery'),
                               ('Construction'),
                               ('Convenience'),
                               ('Copyshop'),
                               ('Cosmetics'),
                               ('Courthouse'),
                               ('Crafts'),
                               ('Courthouse'),
                               ('Cycling'),
                               ('Cycleway'),
                               ('Dance'),
                               ('Deli'),
                               ('Dentist'),
                               ('DepartmentStore'),
                               ('Detached'),
                               ('Doctors'),
                               ('DrinkingWater'),
                               ('DryCleaning'),
                               ('ElectronicsShop'),
                               ('Elevator'),
                               ('EstateAgent'),
                               ('Fabric'),
                               ('FashionShop'),
                               ('FastFood'),
                               ('FireStation'),
                               ('FitnessCentre'),
                               ('Florist'),
                               ('Footway'),
                               ('Fountain'),
                               ('Fraternity'),
                               ('FuneralDirectors'),
                               ('Furniture'),
                               ('Gallery'),
                               ('Gambling'),
                               ('Games'),
                               ('Garage'),
                               ('Garden'),
                               ('Gift'),
                               ('GiveWaySign'),
                               ('Glaziery'),
                               ('GovernmentBuilding'),
                               ('GrassLanduse'),
                               ('Greengrocer'),
                               ('GritBin'),
                               ('GuestHouse'),
                               ('Hackerspace'),
                               ('Hairdresser'),
                               ('Hardware'),
                               ('HealthFood'),
                               ('HearingAids'),
                               ('Hifi'),
                               ('HighwayConstruction'),
                               ('HighwayCrossing'),
                               ('HighwayService'),
                               ('HobbyShop'),
                               ('HomeFurnishing'),
                               ('Hospital'),
                               ('Hostel'),
                               ('Hotel'),
                               ('House'),
                               ('Housewares'),
                               ('IceCream'),
                               ('IndustrialLanduse'),
                               ('IndustrialProductionBuilding'),
                               ('InternetCafe'),
                               ('Jewelry'),
                               ('Kindergarten'),
                               ('Kiosk'),
                               ('KitchenShop'),
                               ('LanguageSchool'),
                               ('Laundry'),
                               ('Library'),
                               ('Lighting'),
                               ('LivingStreet'),
                               ('Locksmith'),
                               ('MassageShop'),
                               ('Marketplace'),
                               ('Meadow'),
                               ('MobilePhone'),
                               ('Monastery'),
                               ('Motorcycle'),
                               ('Museum'),
                               ('Music'),
                               ('MusicalInstrument'),
                               ('Newsagent'),
                               ('Nightclub'),
                               ('OpticianShop'),
                               ('Outdoor'),
                               ('Paint'),
                               ('Park'),
                               ('Parking'),
                               ('ParkingEntrance'),
                               ('ParkingSpace'),
                               ('Pastry'),
                               ('Path'),
                               ('PedestrianUse'),
                               ('Perfumery'),
                               ('PetShop'),
                               ('Pharmacy'),
                               ('Photo'),
                               ('PicnicSite'),
                               ('Pitch'),
                               ('PlaceOfWorship'),
                               ('Platform'),
                               ('Playground'),
                               ('Police'),
                               ('PostBox'),
                               ('PostOffice'),
                               ('Pottery'),
                               ('Pub'),
                               ('PublicBuilding'),
                               ('RailwayLanduse'),
                               ('Recycling'),
                               ('Religious'),
                               ('Rent'),
                               ('ResidentialHighway'),
                               ('ResidentialLanduse'),
                               ('Restaurant'),
                               ('RetailLanduse'),
                               ('Ruins'),
                               ('Sauna'),
                               ('School'),
                               ('Scrub'),
                               ('SecondaryHighway'),
                               ('SecondaryLink'),
                               ('SecondHand'),
                               ('Service'),
                               ('Shed'),
                               ('Shelter'),
                               ('Shoes'),
                               ('Shop'),
                               ('SocialFacility'),
                               ('SpeedCamera'),
                               ('SportsCentre'),
                               ('SportsShop'),
                               ('Stationery'),
                               ('Steps'),
                               ('StreetLamp'),
                               ('Stripclub'),
                               ('Studio'),
                               ('Supermarket'),
                               ('Synagogue'),
                               ('Tailor'),
                               ('Tanning'),
                               ('Tattoo'),
                               ('Taxi'),
                               ('Tea'),
                               ('Telecommunication'),
                               ('Telephone'),
                               ('Terrace'),
                               ('TertiaryHighway'),
                               ('Ticket'),
                               ('Tobacco'),
                               ('Toilets'),
                               ('TourismInformation'),
                               ('TourismThing'),
                               ('Townhall'),
                               ('Toys'),
                               ('Track'),
                               ('TrafficSignals'),
                               ('TrainStation'),
                               ('TravelAgency'),
                               ('Tree'),
                               ('TreeRow'),
                               ('TurningCircle'),
                               ('University'),
                               ('UnclassifiedHighway'),
                               ('Vacant'),
                               ('VendingMachine'),
                               ('Veterinary'),
                               ('VideoGames'),
                               ('VideoShop'),
                               ('Viewpoint'),
                               ('VillageGreen'),
                               ('WasteBasket'),
                               ('WasteDisposal'),
                               ('Watches'),
                               ('Water'),
                               ('Wine'),
                               ('Wood');
ALTER TABLE public.classes ADD COLUMN class_id SERIAL PRIMARY KEY;

-- Clean up entities table and add constraints
-- Clean up some weird id-s
UPDATE public."association_osm" SET osm_id= -osm_id WHERE association_osm.osm_id<0;

-- Remove duplicates based on osm_id
DELETE FROM public."entities"
WHERE ctid NOT IN (
    SELECT min(ctid)                    -- ctid is NOT NULL by definition
    FROM public."entities"
    GROUP BY osm_id);  -- list columns defining duplicates

-- Add respective constraints and primary keys
ALTER TABLE public."entities" ADD CONSTRAINT unique_osmid UNIQUE ("osm_id");
ALTER TABLE ONLY public."entities"
    ADD CONSTRAINT prk_osmid PRIMARY KEY ("osm_id");

-- Ensure all osm_id values are TEXT
ALTER TABLE public.entities
ALTER COLUMN osm_id type TEXT using osm_id::TEXT;

-- Reshape linkage table
-- Add constraints to linkage table
ALTER TABLE public.association_osm ADD COLUMN id SERIAL PRIMARY KEY;
-- Fix constraint association
ALTER TABLE public.association_osm ALTER COLUMN osm_id type TEXT using osm_id::TEXT;
-- Remove any unknown records remaining
DELETE FROM public."association_osm"
WHERE osm_id NOT IN (
    SELECT entities.osm_id
    FROM public."entities");
-- osm2pgsql introducing a few duplicates (ca. 10 records)
DELETE FROM public."association_osm" t1
    USING   public."association_osm" t2
WHERE   t1.id > t2.id
  AND t1.osm_type = t2.osm_type
  AND t1.osm_id  = t2.osm_id
  AND t1.class_id  = t2.class_id;



-- Add remaining FKs
ALTER TABLE ONLY public.association_osm
    ADD CONSTRAINT fk_association_osm_entities FOREIGN KEY ("osm_id") REFERENCES public."entities" ("osm_id");

ALTER TABLE ONLY public.association_osm
    ADD CONSTRAINT fk_association_osm_classes FOREIGN KEY ("class_id") REFERENCES public."classes" ("class_id");



-- Drop tables generated by default by osm2pgsql
DROP TABLE citydb.planet_osm_nodes;
DROP TABLE citydb.planet_osm_ways;
DROP TABLE citydb.planet_osm_rels;

-- Volumes can only be calculated on closed polyhedral surfaces with valid planar polygons
-- Based on discussions:
-- https://github.com/3dcitydb/importer-exporter/issues/193
-- https://gis.stackexchange.com/questions/447297/st-tesselate-on-polyhedralsurface-is-invalid-polygon-0-is-invalid-points-don
-- https://gis.stackexchange.com/questions/447491/why-is-this-polygon-not-planar-for-postgis
-- https://gis.stackexchange.com/questions/429589/postgis-sfcgal-error-polyhedralsurface-is-invalid-inconsistent-orientation-of
--ALTER TABLE citydb.surface_geometry ADD COLUMN solid_closed BOOLEAN;
--ALTER TABLE citydb.surface_geometry ADD COLUMN solid_planar BOOLEAN;
--UPDATE citydb.surface_geometry
--    SET solid_closed = CASE WHEN solid_geometry IS NOT NULL THEN ST_ISCLOSED(solid_geometry) ELSE NULL END ;
--UPDATE citydb.surface_geometry
--    SET solid_planar = CASE WHEN solid_geometry IS NOT NULL THEN ST_ISPLANAR(geom(ST_DUMP(solid_geometry))) ELSE NULL END ;