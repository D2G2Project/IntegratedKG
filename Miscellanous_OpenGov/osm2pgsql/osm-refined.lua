-- This config example file is released into the Public Domain.

-- Taken from https://github.com/openstreetmap/osm2pgsql/blob/master/flex-config/unitable.lua
-- Put all OSM data into a single table

-- inspect = require('inspect')

-- We define a single table that can take any OSM object and any geometry.
-- OSM nodes are converted to Points, ways to LineStrings and relations
-- to GeometryCollections. If an object would create an invalid geometry
-- it is still added to the table with a NULL geometry.
-- XXX expire will currently not work on these tables.
-- A place to store the SQL tables we will define shortly.
local tables = {}

tables.entities = osm2pgsql.define_table{
    name = "entities",
    -- This will generate a column "osm_id INT8" for the id, and a column
    -- "osm_type CHAR(1)" for the type of object: N(ode), W(way), R(relation)
    ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
    columns = {
        { column = 'class',  type = 'text' },
        { column = 'geom',  type = 'geometry', projection = 4326, not_null = true },
        { column = 'name',  type = 'text' },
        { column = 'name_en',  type = 'text' },
        { column = 'name_de',  type = 'text' },
        { column = 'name_fr',  type = 'text' },
        { column = 'name_it',  type = 'text' },
        { column = 'height',  type = 'text' },
        { column = 'country', type = 'text' },
        { column = 'state', type = 'text' },
        { column = 'postcode', type = 'text' },
        { column = 'city', type = 'text' },
        { column = 'place', type = 'text' },
        { column = 'street', type = 'text' },
        { column = 'housenumber', type = 'text' },
        { column = 'type', type = 'text' },
    }
}

-- Table with class names defined separately
tables.classes = osm2pgsql.define_table{
    name = "classes",
    -- This will generate a column "class_id INT8" for the class id
    ids = { type = 'any', id_column = 'id' },
    columns = {
        { column = 'class_name',  type = 'text' },
    }
}

-- Linkage table between classes and osm entities. Many-to-many relationship.
tables.association_osm = osm2pgsql.define_table{
    name = "association_osm",
    -- This will generate a column "class_id INT8" for the class id

    ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
    columns = {
        --    { column = 'osm_id',  type = 'int8' },
        { column = 'class_id',  type = 'int8' },
    }
}

-- List all permitted classes
local orderedList = {
    "AerialwayGoods",
    "AerialwayStation",
    "AerialwayThing",
    "AlcoholShop",
    "AntiquesShop",
    "ApartmentBuilding",
    "ApplianceShop",
    "ArtShop",
    "ArtsCentre",
    "ArtShop",
    "Artwork",
    "ATM",
    "Attraction",
    "BabyGoods",
    "BagsShop",
    "Bakery",
    "Bank",
    "Bar",
    "BathroomFurnishing",
    "BeautyShop",
    "BedShop",
    "Bench",
    "BicycleParking",
    "BicycleRental",
    "BicycleShop",
    "Biergarten",
    "BookmakerShop",
    "BooksShop",
    "Boutique",
    "Bridge",
    "Bridleway",
    "Brownfield",
    "Building",
    "BuildingBarn",
    "BuildingBunker",
    "BuildingCabin",
    "BuildingChapel",
    "BuildingChurch",
    "BuildingCommercial",
    "BuildingDormitory",
    "BuildingGarage",
    "BuildingHospital",
    "BuildingHut",
    "BuildingKiosk",
    "BuildingOffice",
    "BuildingResidential",
    "BuildingRetail",
    "BuildingSchool",
    "BureauDeChange",
    "BusStop",
    "Butcher",
    "CableCar",
    "Cafe",
    "CameraShop",
    "Carpet",
    "CarRental",
    "CarSharing",
    "CarShop",
    "CarWash",
    "Casino",
    "Cemetery",
    "ChairLift",
    "CharityShop",
    "Cheese",
    "Chemist",
    "Childcare",
    "Chocolate",
    "Cinema",
    "City",
    "Clinic",
    "Clock",
    "Clothes",
    "CoffeeShop",
    "Collapsed",
    "College",
    "CommercialLanduse",
    "CommunityCentre",
    "Computer",
    "Confectionery",
    "Construction",
    "Convenience",
    "Copyshop",
    "Cosmetics",
    "Courthouse",
    "Crafts",
    "Courthouse",
    "Cycling",
    "Cycleway",
    "Dance",
    "Deli",
    "Dentist",
    "DepartmentStore",
    "Detached",
    "Doctors",
    "DragLift",
    "DrinkingWater",
    "DryCleaning",
    "ElectronicsShop",
    "Elevator",
    "EstateAgent",
    "Fabric",
    "FashionShop",
    "FastFood",
    "FireStation",
    "FitnessCentre",
    "Florist",
    "Footway",
    "Fountain",
    "Fraternity",
    "FuneralDirectors",
    "Furniture",
    "Gallery",
    "Gambling",
    "Games",
    "Garage",
    "Garden",
    "Gift",
    "GiveWaySign",
    "Glaziery",
    "GovernmentBuilding",
    "GrassLanduse",
    "Greengrocer",
    "GritBin",
    "GuestHouse",
    "Hackerspace",
    "Hairdresser",
    "Hardware",
    "HealthFood",
    "HearingAids",
    "Hifi",
    "HighwayConstruction",
    "HighwayCrossing",
    "HighwayPrimaryLink",
    "HighwaySecondaryLink",
    "HighwayService",
    "HighwayTertiaryLink",
    "HobbyShop",
    "HomeFurnishing",
    "Hospital",
    "Hostel",
    "Hotel",
    "House",
    "Housewares",
    "IceCream",
    "IndustrialLanduse",
    "IndustrialProductionBuilding",
    "InternetCafe",
    "Jewelry",
    "Kindergarten",
    "Kiosk",
    "KitchenShop",
    "LanguageSchool",
    "Laundry",
    "Leisure",
    "Library",
    "Lighting",
    "LivingStreet",
    "Locksmith",
    "MassageShop",
    "Marketplace",
    "Meadow",
    "MiniRoundabout",
    "MixedLift",
    "MobilePhone",
    "Monastery",
    "Motorcycle",
    "Motorway",
    "Museum",
    "Music",
    "MusicalInstrument",
    "NaturalThing",
    "Newsagent",
    "Nightclub",
    "OpticianShop",
    "Outdoor",
    "Paint",
    "Park",
    "Parking",
    "ParkingEntrance",
    "ParkingSpace",
    "Pastry",
    "Path",
    "PedestrianUse",
    "Perfumery",
    "PetShop",
    "Pharmacy",
    "Photo",
    "PicnicSite",
    "Pitch",
    "PlaceOfWorship",
    "Platform",
    "Playground",
    "Police",
    "PostBox",
    "PostOffice",
    "Pottery",
    "PrimaryHighway",
    "ProposedHighway",
    "Pub",
    "PublicBuilding",
    "Raceway",
    "RailwayLanduse",
    "Recycling",
    "Religious",
    "Rent",
    "ResidentialHighway",
    "ResidentialLanduse",
    "RestArea",
    "Restaurant",
    "RetailLanduse",
    "Road",
    "Ruins",
    "Sauna",
    "School",
    "Scrub",
    "SecondaryHighway",
    "SecondaryLink",
    "SecondHand",
    "Service",
    "Shed",
    "Shelter",
    "Shoes",
    "Shop",
    "SocialFacility",
    "SpeedCamera",
    "SportsCentre",
    "SportsShop",
    "Stationery",
    "Steps",
    "StreetLamp",
    "Stripclub",
    "Studio",
    "Supermarket",
    "Synagogue",
    "Tailor",
    "Tanning",
    "Tattoo",
    "Taxi",
    "Tea",
    "Telecommunication",
    "Telephone",
    "Terrace",
    "TertiaryHighway",
    "Ticket",
    "Tobacco",
    "Toilets",
    "TourismInformation",
    "TourismThing",
    "Townhall",
    "Toys",
    "Track",
    "TrafficSignals",
    "TrainStation",
    "TravelAgency",
    "Tree",
    "TreeRow",
    "Trunk",
    "TrunkLink",
    "TurningCircle",
    "University",
    "UnclassifiedHighway",
    "Vacant",
    "VendingMachine",
    "Veterinary",
    "VideoGames",
    "VideoShop",
    "Viewpoint",
    "VillageGreen",
    "WasteBasket",
    "WasteDisposal",
    "Watches",
    "Water",
    "Wine",
    "Wood"
}


-- Helper function to remove some of the tags we usually are not interested in.
-- Returns true if there are no tags left.
function clean_tags(tags)
    tags.odbl = nil
    tags.created_by = nil
    tags.source = nil
    tags['source:ref'] = nil

    return next(tags) == nil
end

-- Helper function to check whether string starts with substring
local function starts_with(str, sta)
    lcase_str = string.lower(str)
    return lcase_str:sub(1, #sta) == sta
end

-- Helper function to make string first letter uppercase
local function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

-- check whether string contains substring
local function contains(list, x)
    for _, v in pairs(list) do
        if v == x then return true end
    end
    return false
end

-- removes underscores from a string, capitalizes its elements, and reattaches
local function removeUnderscoreAndCapitalize(str)
    local words = {}
    for word in str:gmatch("[^_]+") do
        table.insert(words, word:sub(1, 1):upper() .. word:sub(2))
    end
    return table.concat(words)
end


-- We filter only the OSM items of interest
-- Superclasses
-- Set variable which lists objects we are interested in
local filteredlist = { "highway", "building", "amenity", "shop", "natural", "place", "landuse", "tourism", "leisure",
                       "aeroway", "aerialway"} -- No items for the last 2 in munich
-- Within Building
local buildingUndescoreList = { "sports_centre", "train_station"}
local buildingSuperclassSubclassList = {"barn", "bunker", "cabin", "chapel", "church", "commercial", "office", "retail",
                                        "kiosk", "garage", "hospital",  "school", "dormitory", "hut", "residential"}
local buildingSubclassSuperclassList = { "public", "government"}
local buildingSubclassList = { "hotel", "university", "house", "bridge", "elevator", "construction", "shed", "parking",
                               "service", "kindergarten", "terrace", "college", "ruins", "synagogue", "detached", "collapsed" }
-- Highway
local highwayUndescoreList = { "turning_circle", "traffic_signals", "street_lamp", "speed_camera", "living_street",
                               "bus_stop", "mini_roundabout", "rest_area", "service_station", "trunk_link"}
local highwaySuperclassSubclassList = {"construction", "crossing", "ford", "service", "primary_link", "secondary_link", "tertiary_link"}
local highwaySubclassSuperclassList = { "primary", "secondary", "tertiary", "unclassified", "residential", "proposed"}
local highwaySubclassList = { "steps", "platform", "path", "footway", "elevator", "bridleway", "busguideway",
                              "byway", "cycleway", "emergencyaccesspoint", "motorway", "passingplance", "raceway",
                              "road", "track", "trunk" }
-- Amenity
local amenityUndescoreList = { "vending_machine", "bicycle_parking", "waste_basket", "fast_food", "parking_entrance",
                               "place_of_worship", "grit_bin", "ice_cream", "bicycle_rental", "arts_centre", "community_centre",
                               "social_facility", "car_rental", "car_sharing", "bureau_de_change", "drinking_water",
                               "post_office", "post_box", "parking_space", "internet_cafe", "language_school", "waste_disposal",
                               "fire_station", "public_building", "car_wash", "fire_station"}

local amenitySubclassList = { "bench", "restaurant", "cafe", "parking", "fountain", "shelter", "bar", "doctors",
                              "telephone", "bank", "pharmacy", "taxi", "pub", "school", "university", "dentist", "theater",
                              "kindergarten", "nightclub", "cinema", "toilets", "studio", "library", "hospital", "biergarten", "courthouse",
                              "recycling", "police", "clock", "clinic", "college", "childcare", "gambling", "marketplace", "monastery",
                              "casino", "townhall", "stripclub", "fraternity", "veterinary", "tailor" }
-- Shop
local shopUndescoreList = { "mobile_phone", "travel_agency", "department_store", "hearing_aids", "dry_cleaning",
                            "health_food", "funeral_directors", "bathroom_furnishing", "musical_instrument", "second_hand",
                            "video_games", "estate_agent", "baby_goods"}
local shopSubclassSuperclassList = { "art", "optician", "beauty", "sports", "books", "antiques", "bicycle", "car",
                                     "electronics", "coffee", "bookmaker", "alcohol", "bed", "massage", "kitchen", "camera", "pet", "appliance", "video",
                                     "charity", "fitness", "fitness"}
local shopSubclassList = { "clothes", "hairdresser", "jewelry", "bakery", "shoes", "furniture", "supermarket", "gift",
                           "deli", "cosmetics", "butcher", "convenience", "chemist", "kiosk", "greengrocer", "ticket", "vacant", "confectionery",
                           "fabric", "perfumery", "watches", "tobacco", "florist", "computer", "wine", "tailor",
                           "outdoor", "copyshop", "tea", "tattoo", "photo", "newsagent", "variety", "hifi", "stationery",
                           "lighting", "music", "chocolate", "locksmith", "pottery", "toys", "games", "laundry", "carpet",
                           "paint", "pastry", "boutique", "motorcycle", "cheese", "hardware", "glaziery", "glass", "telecommunication" }
-- Natural
local naturalUndescoreList = { "tree_row"}
local naturalSubclassList = { "tree", "water", "wood", "scrub" }
-- Place
local placeSubclassList = { "city", "sububrb" }
-- Landuse
local landuseUndescoreList = { "village_green"}
local landuseSubclassSuperclassList = { "grass", "residential", "commercial", "retail", "railway", "industrial"}
local landuseSubclassList = { "meadow", "brownfield", "cemetery" }
-- Tourism
local tourismUndescoreList = { "guest_house", "picnic_site"}
local tourismSuperclassSubclassList = {"information"}
local tourismSubclassList = { "hotel", "artwork", "gallery", "attraction", "museum", "hostel", "viewpoint", "casino" }
-- Leisure
local leisureUndescoreList = { "fitness_centre", "sports_centre"}
local leisureSubclassList = { "park", "garden", "playground", "pitch", "dance", "hackerspace", "sauna", "track" }
-- Aerialway
local aerialwayUndescoreList = { "mixed_lift", "drag_lift", "chair_lift", "cable_car"}
local aerialwaySubclassSuperclassList = { "goods", "station" }


-- Handle quite common scenarios
-- e.g. 1) building=yes 2) highway=primary
local function refineclasses(list1, k ,v)
    k_upper = firstToUpper(k)
    v_upper = firstToUpper(v)
    -- Only select classes defined in the LGD ontology
    if not contains(list1, k) then
        return "do_nothing"
        -- Superclasses
    elseif (starts_with(k, "building") or starts_with(k, "amenity") or starts_with(k, "shop")
            or starts_with(k, "place") or starts_with(k, "landuse") or starts_with(k, "leisure"))
            and starts_with(v, "yes")
    then return k_upper
    elseif (starts_with(k, "highway") or starts_with(k, "tourism") or starts_with(k, "natural")
            or starts_with(k, "aeroway") or starts_with(k, "aerialway")) and starts_with(v, "yes")
    then return k_upper.."Thing"

        -- Building
    elseif starts_with(k, "building") and contains(buildingUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "building") and starts_with(v, "garages") then
        return "BuildingGarage"
    elseif starts_with(k, "building") and contains(buildingSuperclassSubclassList, v)
    then return k_upper .. v_upper
    elseif starts_with(k, "building") and contains(buildingSubclassSuperclassList, v)
    then return v_upper .. k_upper
    elseif starts_with(k, "building") and contains(buildingSubclassList, v)
    then return v_upper
    elseif starts_with(k, "building") and starts_with(v, "apartments") then
        return "ApartmentBuilding"
    elseif starts_with(k, "building") and starts_with(v, "industrial") then
        return "IndustrialProductionBuilding"

        -- Highway
    elseif starts_with(k, "highway") and contains(highwaySuperclassSubclassList, v)
    then return k_upper .. removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "highway") and contains(highwayUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "highway") and contains(highwaySubclassSuperclassList, v)
    then return v_upper .. k_upper
    elseif starts_with(k, "highway") and contains(highwaySubclassList, v)
    then return v_upper
    elseif starts_with(k, "highway") and (starts_with(v, "pedestrian"))
    then return "PedestrianUse"
    elseif starts_with(k, "highway") and (starts_with(v, "give_way"))
    then return "GiveWaySign"

        -- Amenity
    elseif starts_with(k, "amenity") and contains(amenitySubclassList, v)
    then return v_upper
    elseif starts_with(k, "amenity") and contains(amenityUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "amenity") and starts_with(v, "atm")
    then return "ATM"

        -- Shop
    elseif starts_with(k, "shop") and contains(shopSubclassList, v)
    then return v_upper
    elseif starts_with(k, "shop") and contains(shopSubclassSuperclassList, v)
    then return v_upper..k_upper
    elseif starts_with(k, "shop") and contains(shopUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "shop") and starts_with(v, "bag")
    then return "BagsShop"
    elseif starts_with(k, "shop") and starts_with(v, "fashion_accessories")
    then return "FashionShop"
    elseif starts_with(k, "shop") and starts_with(v, "houseware")
    then return "Housewares"
    elseif starts_with(k, "shop") and starts_with(v, "craft")
    then return "Crafts"

        -- Natural
    elseif starts_with(k, "natural") and contains(naturalSubclassList, v)
    then return v_upper
    elseif starts_with(k, "natural") and contains(naturalUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)

        -- Place
    elseif starts_with(k, "place") and contains(placeSubclassList, v)
    then return v_upper

        --Landuse
    elseif starts_with(k, "landuse") and contains(landuseSubclassList, v)
    then return v_upper
    elseif starts_with(k, "landuse") and contains(landuseSubclassSuperclassList, v)
    then return v_upper..k_upper
    elseif starts_with(k, "landuse") and contains(landuseUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)

        -- Tourism
    elseif starts_with(k, "tourism") and contains(tourismSubclassList, v)
    then return v_upper
    elseif starts_with(k, "tourism") and contains(tourismSuperclassSubclassList, v)
    then return k_upper..v_upper
    elseif starts_with(k, "tourism") and contains(tourismUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "tourism") and (starts_with(v, "apartment") )
    then return "ApartmentBuilding"

        -- Leisure
    elseif starts_with(k, "leisure") and contains(leisureSubclassList, v)
    then return v_upper
    elseif starts_with(k, "leisure") and contains(leisureUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    elseif starts_with(k, "leisure") and (starts_with(v, "tanning_salon") )
    then return "Tanning"
    elseif starts_with(k, "tourism") and (starts_with(v, "apartment") )
    then return "ApartmentBuilding"
    --elseif starts_with(k, "leisure") and starts_with(v, "yes")
    --then return "Leisure"

        -- Aerialway
    elseif starts_with(k, "aerialway") and contains(aerialwaySubclassSuperclassList, v)
    then return k_upper..v_upper
    elseif starts_with(k, "aerialway") and contains(aerialwayUndescoreList, v)
    then return removeUnderscoreAndCapitalize(v)
    --elseif starts_with(k, "aerialway") and starts_with(v, "yes")
    --then return "AerialwayThing"

    else
        return "do_nothing"
        --return v_upper
    end
end


local function mapToValue(val)
    for key, value in ipairs(orderedList) do
        if value == val then
            return key
        end
    end
end


-- Helper function to fill up table
local function filluptable(object, geometry)

    local refinedval
    for k, v in pairs(object.tags) do
        local refinedvalcheck = refineclasses(filteredlist, k ,v)
        refinedval = refinedvalcheck
        if (refinedval == "do_nothing") then
            --pass if not in list of classes of interest
        else

            tables.entities:insert({
                class = mapToValue(refinedval),
                geom = geometry,
                name = object.tags.name,
                name_en = object.tags['name:en'],
                name_de = object.tags['name:de'],
                name_fr = object.tags['name:fr'],
                name_it = object.tags['name:it'],
                height = object.tags['height'],
                country = object.tags["addr:country"],
                state = object.tags["addr:state"],
                postcode = object.tags["addr:postcode"],
                city = object.tags["addr:city"],
                place = object.tags["addr:place"],
                street = object.tags["addr:street"],
                housenumber = object.tags["addr:housenumber"],
                type = object.tags["type"]
            })

            tables.association_osm:insert({
                --    osm_id = object.tags.osm_id,
                class_id = mapToValue(refinedval)
            })
        end
    end
end


function process(object, geometry)
    -- If after removing the useless tags there is nothing left, ignore,
    -- we do not know what the object is
    if clean_tags(object.tags) then
        return
    end

    -- Set a list of superclasses/keys we care about and fill-up OSM table
    filluptable(object, geometry)

end

function osm2pgsql.process_node(object)
    process(object, object:as_point())
end

function osm2pgsql.process_way(object)
    if object.is_closed
    --and has_area_tags(object.tags)
    then
        process(object, object:as_polygon())
    else
        process(object, object:as_linestring())
    end
end

-- NOTE: Iterating over all members might further reduce geometry collections
function osm2pgsql.process_relation(object)
    local relation_type = object:grab_tag('type')
    if relation_type == 'multipolygon' then
        process(object, object:as_multipolygon())
    elseif relation_type == 'multilinestring' then
        process(object, object:as_multilinestring())
    elseif relation_type == 'multipoint' then
        process(object, object:as_multipoint())
    else
        process(object, object:as_geometrycollection())
    end
end