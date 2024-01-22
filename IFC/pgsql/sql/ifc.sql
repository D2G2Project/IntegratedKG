CREATE TABLE public."IfcSite"

(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "GlobalId" TEXT,
    "Name" TEXT,
    "Description" TEXT,
    "ObjectType" TEXT,
    "LongName" TEXT,
    "CompositionType" TEXT,
    "RefElevation" DOUBLE PRECISION,
    "LandTitleNumber" TEXT,
    "SiteAddress" TEXT,
    "RefLatitude" TEXT,
    "RefLongitude" TEXT,
    lat_degrees BIGINT,
    lat_minutes BIGINT,
    lat_seconds BIGINT,
    lat_millionthseconds BIGINT,
    lng_degrees BIGINT,
    lng_minutes BIGINT,
    lng_seconds BIGINT,
    lng_millionthseconds BIGINT,
    "OwnerHistory_id" BIGINT,
    "ObjectPlacement_id" BIGINT,
    "Representation_id" BIGINT
);


CREATE TABLE public."IfcBuilding"

(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "GlobalId" TEXT,
    "Name" TEXT,
    "Description" TEXT,
    "ObjectType" TEXT,
    "LongName" TEXT,
    "CompositionType" TEXT,
    "ElevationOfRefHeight" TEXT,
    "ElevationOfTerrain" TEXT,
    "BuildingAddress" TEXT,
    "OwnerHistory_id" BIGINT,
    "ObjectPlacement_id" BIGINT,
    "Representation_id" BIGINT
);

CREATE TABLE public."IfcDoor"

(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "GlobalId" TEXT,
    "Name" TEXT,
    "Description" TEXT,
    "ObjectType" TEXT,
    "Tag" TEXT,
    "OverallHeight" DOUBLE PRECISION,
    "OverallWidth" DOUBLE PRECISION,
    "PredefinedType" TEXT,
    "OperationType" TEXT,
    "UserDefinedOperationType" TEXT,
    "OwnerHistory_id" BIGINT,
    "ObjectPlacement_id" BIGINT,
    "Representation_id" BIGINT
);


CREATE TABLE public."IfcElementQuantity"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "GlobalId" TEXT,
    "Name" TEXT,
    "Description" TEXT,
    "MethodOfMeasurement" TEXT,
    "OwnerHistory_id" BIGINT
);

CREATE TABLE public."IfcQuantity"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Name" TEXT,
    "Description" TEXT,
    "Unit" TEXT,
    "Value" DOUBLE PRECISION,
    "Formula" TEXT,
    "ElementQuantity_id" BIGINT
);

ALTER TABLE ONLY public."IfcQuantity"
    ADD CONSTRAINT fk_elementquantity FOREIGN KEY ("ElementQuantity_id") REFERENCES public."IfcElementQuantity"(id);

CREATE TABLE public."IfcOwnerHistory"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "State" TEXT,
    "ChangeAction" TEXT,
    "LastModifiedDate" TEXT,
    "LastModifyingUser" TEXT,
    "LastModifyingApplication" TEXT,
    "CreationDate" BIGINT,
    "OwningUser_id" BIGINT,
    "OwningApplication_id" BIGINT
);

ALTER TABLE ONLY public."IfcSite"
    ADD CONSTRAINT fk_ownerhistory FOREIGN KEY ("OwnerHistory_id") REFERENCES public."IfcOwnerHistory"(id);

ALTER TABLE ONLY public."IfcBuilding"
    ADD CONSTRAINT fk_ownerhistory FOREIGN KEY ("OwnerHistory_id") REFERENCES public."IfcOwnerHistory"(id);

ALTER TABLE ONLY public."IfcDoor"
    ADD CONSTRAINT fk_ownerhistory FOREIGN KEY ("OwnerHistory_id") REFERENCES public."IfcOwnerHistory"(id);

CREATE TABLE public."IfcObjectPlacement"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "PlacementRelTo_id" TEXT,
    "RelativePlacement_id" TEXT
);


CREATE TABLE public."IfcRepresentation"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "RepresentationIdentifier" TEXT,
    "RepresentationType" TEXT,
    "ContextOfItems_id" BIGINT
);

CREATE TABLE public."IfcDirection"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "DirectionRatios" TEXT
);


CREATE TABLE public."IfcAxis2Placement2D"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Location_id" BIGINT,
    "Direction_id" BIGINT
);

CREATE TABLE public."IfcAxis2Placement3D"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Location_id" BIGINT,
    "Direction_id" BIGINT,
    "Axis_id" BIGINT
);

CREATE TABLE public."IfcCartesianPoint"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Coordinates" TEXT,
    "x" DOUBLE PRECISION,
    "y" DOUBLE PRECISION,
    "z" DOUBLE PRECISION
);

CREATE TABLE public."IfcFacetedBrep"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Representation_id" BIGINT,
    "Outer_id" BIGINT
);

ALTER TABLE ONLY public."IfcFacetedBrep"
    ADD CONSTRAINT fk_representation FOREIGN KEY ("Representation_id") REFERENCES public."IfcRepresentation"(id);


CREATE TABLE public."IfcApplication"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Version" TEXT,
    "ApplicationFullName" TEXT,
    "ApplicationIdentifier" TEXT,
    "ApplicationDeveloper_id" BIGINT
);

CREATE TABLE public."IfcPersonAndOrganization"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Roles" TEXT,
    "ThePerson_id" BIGINT,
    "TheOrganization_id" BIGINT
);

CREATE TABLE public."IfcOrganization"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Identification" TEXT,
    "Name" TEXT,
    "Description" TEXT,
    "Roles" TEXT,
    "Addresses" TEXT
);

CREATE TABLE public."IfcPerson"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Identification" TEXT,
    "FamilyName" TEXT,
    "GivenName" TEXT,
    "MiddleNames" TEXT,
    "PrefixTitles" TEXT,
    "SuffixTitles" TEXT,
    "Roles" TEXT,
    "Addresses" TEXT
);


CREATE TABLE public."IfcRepresentationContext"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "ContextIdentifier" TEXT,
    "ContextType" TEXT,
    "CoordinateSpaceDimension" DOUBLE PRECISION,
    "Precision" DOUBLE PRECISION,
    "TargetScale" DOUBLE PRECISION,
    "TargetView" TEXT,
    "UserDefinedTargetView" TEXT,
    "WorldCoordinateSystem_id" BIGINT,
    "TrueNorth_id" BIGINT,
    "ParentContext_id" BIGINT
);

CREATE TABLE public."IfcSweptAreaSolid"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "Depth" DOUBLE PRECISION,
    "SweptArea_id" BIGINT,
    "Position_id" BIGINT,
    "ExtrudedDirection_id" BIGINT
);

CREATE TABLE public."IfcRectangleProfileDef"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "ProfileType" TEXT,
    "ProfileName" TEXT,
    "XDim" DOUBLE PRECISION,
    "YDim" DOUBLE PRECISION,
    "Position_id" BIGINT
);

CREATE TABLE public."IfcArbitraryClosedProfileDef"
(
    id BIGINT NOT NULL PRIMARY KEY,
    "type" TEXT,
    "ProfileType" TEXT,
    "ProfileName" TEXT,
    "OuterCurve_id" BIGINT
);

ALTER TABLE ONLY public."IfcOwnerHistory"
    ADD CONSTRAINT fk_owninguser FOREIGN KEY ("OwningUser_id") REFERENCES public."IfcPersonAndOrganization"(id);

ALTER TABLE ONLY public."IfcOwnerHistory"
    ADD CONSTRAINT fk_owningapplication FOREIGN KEY ("OwningApplication_id") REFERENCES public."IfcApplication"(id);

ALTER TABLE ONLY public."IfcPersonAndOrganization"
    ADD CONSTRAINT fk_organization FOREIGN KEY ("TheOrganization_id") REFERENCES public."IfcOrganization"(id);

ALTER TABLE ONLY public."IfcApplication"
    ADD CONSTRAINT fk_organization FOREIGN KEY ("ApplicationDeveloper_id") REFERENCES public."IfcOrganization"(id);

ALTER TABLE ONLY public."IfcPersonAndOrganization"
    ADD CONSTRAINT fk_person FOREIGN KEY ("ThePerson_id") REFERENCES public."IfcPerson"(id);