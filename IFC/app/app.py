import ifcopenshell
import pandas as pd
import sqlalchemy
from sqlalchemy import text

def open_ifc(file_path):
    return ifcopenshell.open(file_path)

# Load IfcElements into a dataframe
def loadIfcElement(model, IfcElementString):
    elements = model.by_type(IfcElementString)
    ElementList = []
    for element in elements:
        ElementList.append(element.get_info())
    return pd.DataFrame.from_dict(ElementList)

# Extract ID in order to create FK
def createReference(xval):
    if pd.isnull(xval):
        return None
    else:
        return (xval.split('#'))[1].split('=')[0]

# Extract Directions
def extractDirection(xval):
    if pd.isnull(xval):
        return None
    else:
        dirval = (xval.split('(('))[1].split('))')[0]
        dirval2 = '(' + dirval + ')'
        dirval3 = dirval2.replace(".,", ".0," )
        dirval4 = dirval3.replace(",", ", " )
        dirval5 = dirval4.replace("E-", "e-0")
        return dirval5.replace(".)", ".0)")

model = open_ifc(r'AC20-FZK-Haus.ifc')
engine = sqlalchemy.create_engine(f'postgresql://ifcsql:ifcsql@host.docker.internal:7778/ifcsql')

### 16. IfcOrganization
organization = model.by_type("IfcOrganization")
OrganizationList = []
for element in organization:
    OrganizationList.append(element.get_info())
df_organization = pd.DataFrame.from_dict(OrganizationList)
df_organization.to_sql("IfcOrganization", engine, if_exists='append', index=False)


### 17. IfcPerson
person = model.by_type("IfcPerson")
PersonList = []
for element in person:
    PersonList.append(element.get_info())
df_person = pd.DataFrame.from_dict(PersonList)
df_person.to_sql("IfcPerson", engine, if_exists='append', index=False)

### 14. IfcPersonAndOrganization
personandorganization = model.by_type("IfcPersonAndOrganization")
PersonAndOrganizationList = []
for element in personandorganization:
    PersonAndOrganizationList.append(element.get_info())
df_pointandorganization = pd.DataFrame.from_dict(PersonAndOrganizationList)
df_pointandorganization['ThePerson_id'] = df_pointandorganization['ThePerson'].astype('string').apply(createReference)
df_pointandorganization['TheOrganization_id'] = df_pointandorganization['TheOrganization'].astype('string').apply(createReference)
df_pointandorganization.drop(columns=['ThePerson', 'TheOrganization'], inplace=True)
df_pointandorganization.to_sql("IfcPersonAndOrganization", engine, if_exists='append', index=False)

### 15. IfcApplication
application = model.by_type("IfcApplication")
ApplicationList = []
for element in application:
    ApplicationList.append(element.get_info())
df_application = pd.DataFrame.from_dict(ApplicationList)
df_application['ApplicationDeveloper_id'] = df_application['ApplicationDeveloper'].astype('string').apply(createReference)
df_application.drop(columns=['ApplicationDeveloper'], inplace=True)
df_application.to_sql("IfcApplication", engine, if_exists='append', index=False)

### 6. IfcOwnerHistory
df_ownerhistory = loadIfcElement(model, "IfcOwnerHistory")
df_ownerhistory['OwningUser_id'] = df_ownerhistory['OwningUser'].astype('string').apply(createReference)
df_ownerhistory['OwningApplication_id'] = df_ownerhistory['OwningApplication'].astype('string').apply(createReference)
df_ownerhistory.drop(columns=['OwningUser', 'OwningApplication'], inplace=True)
df_ownerhistory.to_sql("IfcOwnerHistory", engine, if_exists='append', index=False)

### 1. IfcSite
df_site = loadIfcElement(model, "IfcSite")
# TODO: There can be 3 or 4 elements, the 4th is optional, we need to account for that
# NOTE: This is WGS84
df_site2 = df_site.join(pd.DataFrame(df_site['RefLatitude'].to_list(), columns=['lat_degrees', 'lat_minutes', 'lat_seconds', 'lat_millionthseconds']))
df_site3 = df_site2.join(pd.DataFrame(df_site['RefLongitude'].to_list(), columns=['lng_degrees', 'lng_minutes', 'lng_seconds', 'lng_millionthseconds']))
df_site3['OwnerHistory_id'] = (df_site3['OwnerHistory'].astype('string').iloc[0].split('#'))[1].split('=')[0]
df_site3['ObjectPlacement_id'] = (df_site3['ObjectPlacement'].astype('string').iloc[0].split('#'))[1].split('=')[0]
df_site3['Representation_id'] = (df_site3['Representation'].astype('string').iloc[0].split('#'))[1].split('=')[0]
df_site3.drop(columns=['OwnerHistory', 'ObjectPlacement', 'Representation'], inplace=True)

# Numpy arrays do not seem to be supported
df_site3.to_sql("IfcSite", engine, if_exists='append', index=False)
# t = text('ALTER TABLE "IfcSite" ADD PRIMARY KEY ("id");')
# with engine.connect() as con:
#     con.execute(t)

### 2. IfcBuilding
df_building = loadIfcElement(model, "IfcBuilding")
df_building['OwnerHistory_id'] = df_building['OwnerHistory'].astype('string').apply(createReference)
df_building['ObjectPlacement_id'] = df_building['ObjectPlacement'].astype('string').apply(createReference)
df_building['Representation_id'] = df_building['Representation'].astype('string').apply(createReference)
df_building.drop(columns=['OwnerHistory', 'ObjectPlacement', 'Representation'], inplace=True)
df_building.to_sql("IfcBuilding", engine, if_exists='append', index=False)

### 3. IfcDoor
df_door = loadIfcElement(model, "IfcDoor")
df_door['OwnerHistory_id'] = df_door['OwnerHistory'].astype('string').apply(createReference)
df_door['ObjectPlacement_id'] = df_door['ObjectPlacement'].astype('string').apply(createReference)
df_door['Representation_id'] = df_door['Representation'].astype('string').apply(createReference)
df_door.drop(columns=['OwnerHistory', 'ObjectPlacement', 'Representation'], inplace=True)
df_door.to_sql("IfcDoor", engine, if_exists='append', index=False)

### 4. IfcElementQuantity
df_elementquantity = loadIfcElement(model, "IfcElementQuantity")
df_elementquantity['OwnerHistory_id'] = df_elementquantity['OwnerHistory'].astype('string').apply(createReference)
# NOTE: Since IfcQuantityLength, IfcQuantityArea, IfcQuantityVolume and IfcQuantityCount constitute
# one-to-many relationships from this table, rather than provide a reference here, we drop Quantities
# instead we use the id here as a PK to those tables
# must use the inverse to achieve that
df_elementquantity.drop(columns=['OwnerHistory', 'Quantities'], inplace=True)
df_elementquantity.to_sql("IfcElementQuantity", engine, if_exists='append', index=False)

### 5. IfcQuantity
counts = model.by_type("IfcQuantityCount")
CountList = []
FKListC = []
for element in counts:
    CountList.append(element.get_info())
    FKListC.append(model.get_inverse(element))
df_counts = pd.DataFrame.from_dict(CountList)
df_counts.rename(columns={"CountValue": "Value"}, inplace=True)
df_counts["tempFK"] = FKListC
df_counts["ElementQuantity_id"] = df_counts['tempFK'].astype('string').apply(createReference)

volumes = model.by_type("IfcQuantityVolume")
VolumeList = []
FKListV = []
for element in volumes:
    VolumeList.append(element.get_info())
    FKListV.append(model.get_inverse(element))
df_volumes = pd.DataFrame.from_dict(VolumeList)
df_volumes.rename(columns={"VolumeValue": "Value"}, inplace=True)
df_volumes["tempFK"] = FKListV
df_volumes["ElementQuantity_id"] = df_volumes['tempFK'].astype('string').apply(createReference)

areas = model.by_type("IfcQuantityArea")
AreaList = []
FKListA = []
for element in areas:
    AreaList.append(element.get_info())
    FKListA.append(model.get_inverse(element))
df_areas = pd.DataFrame.from_dict(AreaList)
df_areas.rename(columns={"AreaValue": "Value"}, inplace=True)
df_areas["tempFK"] = FKListA
df_areas["ElementQuantity_id"] = df_areas['tempFK'].astype('string').apply(createReference)

lengths = model.by_type("IfcQuantityLength")
LengthList = []
FKListL = []
for element in lengths:
    LengthList.append(element.get_info())
    FKListL.append(model.get_inverse(element))
df_lengths = pd.DataFrame.from_dict(LengthList)
df_lengths.rename(columns={"LengthValue": "Value"}, inplace=True)
df_lengths["tempFK"] = FKListL
df_lengths["ElementQuantity_id"] = df_lengths['tempFK'].astype('string').apply(createReference)

frames = [df_counts, df_volumes, df_areas, df_lengths]
df_quantities = pd.concat(frames)
df_quantities.drop(columns=['tempFK'], inplace=True)

df_quantities.to_sql("IfcQuantity", engine, if_exists='append', index=False)

### 7. IfcObjectPlacement
#NOTE: IfcLocalPlacement is a subclass of IfcObjectPlacement
# Detailed description of what it signifies is here: https://standards.buildingsmart.org/IFC/RELEASE/IFC4_1/FINAL/HTML/link/ifcsite.htm
df_objectplacement = loadIfcElement(model, "IfcObjectPlacement")
df_objectplacement['PlacementRelTo_id'] = df_objectplacement['PlacementRelTo'].astype('string').apply(createReference)
df_objectplacement['RelativePlacement_id'] = df_objectplacement['RelativePlacement'].astype('string').apply(createReference)
df_objectplacement.drop(columns=['PlacementRelTo', 'RelativePlacement'], inplace=True)
df_objectplacement.to_sql("IfcObjectPlacement", engine, if_exists='append', index=False)


### 8. IfcRepresentation
df_representation = loadIfcElement(model, "IfcRepresentation")
df_representation['ContextOfItems_id'] = df_representation['ContextOfItems'].astype('string').apply(createReference)
df_representation.drop(columns=['ContextOfItems', 'Items'], inplace=True)
df_representation.to_sql("IfcRepresentation", engine, if_exists='append', index=False)


### 9. IfcDirection
df_direction = loadIfcElement(model, "IfcDirection")
# NOTE: Few unique directions of interest
df_directionnames = df_direction.DirectionRatios.unique()
df_direction2 = pd.DataFrame.from_dict(df_directionnames)
df_direction2['id'] = df_direction2.index + 1
df_direction2['DirectionRatios'] = df_direction2.iloc[: , 0:1]
df_direction2.drop(columns=df_direction2.columns[0], axis=1, inplace=True)
df_direction2['DirectionRatios'] = df_direction2['DirectionRatios'].astype('string')
df_direction2.to_sql("IfcDirection", engine, if_exists='append', index=False)

### 10. IfcAxis2Placement2D
# NOTE: Unfortunately ifcopenshell cannot get all IfcAxis2Placement2D and 3D together
# We need to get the 2D and 3D separately
df_relativeplacement = loadIfcElement(model, "IfcAxis2Placement2D")
df_relativeplacement['Location_id'] = df_relativeplacement['Location'].astype('string').apply(createReference)
df_relativeplacement['Direction_id'] = df_relativeplacement['RefDirection'].astype('string').apply(extractDirection)
df_relativeplacement['Direction_id'] = df_relativeplacement['Direction_id'].astype('string')
df_relativeplacement2 = df_relativeplacement.merge(df_direction2, left_on='Direction_id', right_on='DirectionRatios', how='left')
df_relativeplacement2.drop(columns=['Direction_id', 'DirectionRatios'], inplace=True)
df_relativeplacement2['Direction_id'] = df_relativeplacement2['id_y']
df_relativeplacement2['id'] = df_relativeplacement2['id_x']
df_relativeplacement2.drop(columns=['id_x', 'id_y', 'Location', 'RefDirection'], inplace=True)
df_relativeplacement2.to_sql("IfcAxis2Placement2D", engine, if_exists='append', index=False)


### 11. IfcAxis2Placement3D
df_relativeplacement3d = loadIfcElement(model, "IfcAxis2Placement3D")
df_relativeplacement3d['Location_id'] = df_relativeplacement3d['Location'].astype('string').apply(createReference)
# NOTE: Direction is fundamentally one of 4 or 27 values based on 2D or 3D, it does not make sense to have too many IDs here
df_relativeplacement3d['Direction_id'] = df_relativeplacement3d['RefDirection'].astype('string').apply(extractDirection)
df_relativeplacement3d['Direction_id'] = df_relativeplacement3d['Direction_id'].astype('string')
df_relativeplacement3d['Axis_id'] = df_relativeplacement3d['Axis'].astype('string').apply(extractDirection)
df_relativeplacement3d['Axis_id'] = df_relativeplacement3d['Axis_id'].astype('string')

df_relativeplacement3d2 = df_relativeplacement3d.merge(df_direction2, left_on='Direction_id', right_on='DirectionRatios', how='left')
df_relativeplacement3d2.drop(columns=['Direction_id', 'DirectionRatios'], inplace=True)
df_relativeplacement3d2['Direction_id'] = df_relativeplacement3d2['id_y']
df_relativeplacement3d2['id'] = df_relativeplacement3d2['id_x']
df_relativeplacement3d2.drop(columns=['id_x', 'id_y'], inplace=True)

df_relativeplacement3d3 = df_relativeplacement3d2.merge(df_direction2, left_on='Axis_id', right_on='DirectionRatios', how='left')
df_relativeplacement3d3.drop(columns=['Axis_id', 'DirectionRatios'], inplace=True)
df_relativeplacement3d3['Axis_id'] = df_relativeplacement3d3['id_y']
df_relativeplacement3d3['id'] = df_relativeplacement3d3['id_x']
df_relativeplacement3d3.drop(columns=['id_x', 'id_y'], inplace=True)

df_relativeplacement3d3.drop(columns=['Axis', 'RefDirection', 'Location'], inplace=True)

df_relativeplacement3d3.to_sql("IfcAxis2Placement3D", engine, if_exists='append', index=False)


### 12. IfcCartesianPoint
df_cartesianpoint = loadIfcElement(model, "IfcCartesianPoint")
# TODO: There can be ONLY 2 coordinates i.e. x and y, it is allowed
df_cartesianpoint2 = df_cartesianpoint.join(pd.DataFrame(df_cartesianpoint['Coordinates'].to_list(), columns=['x', 'y', 'z']))
df_cartesianpoint2.to_sql("IfcCartesianPoint", engine, if_exists='append', index=False)


### 13. IfcFacetedBRep
facetedbrep = model.by_type("IfcFacetedBRep")
FacetedBRepList = []
# TODO: IfcFacetedBRep, get FK to this table
FKListC = []
i = 0
for element in facetedbrep:
    FacetedBRepList.append(element.get_info())
    # The inverse includes IfcStyledItems and IfcRepresentations
    inverseSet = model.get_inverse(element)
    listOfInverses = list(inverseSet)
    for value in listOfInverses:
        if value != None and value.is_a('IfcRepresentation'):
            FKListC.append(value)
            break
        elif (listOfInverses.index(value) == len(listOfInverses)):
            FKListC.append(None)
df_facetedbrep = pd.DataFrame.from_dict(FacetedBRepList)
df_facetedbrep["tempFK"] = FKListC
df_facetedbrep["Representation_id"] = df_facetedbrep['tempFK'].astype('string').apply(createReference)
df_facetedbrep['Outer_id'] = df_facetedbrep['Outer'].astype('string').apply(createReference)
df_facetedbrep.drop(columns=['Outer', 'tempFK'], inplace=True)
df_facetedbrep.to_sql("IfcFacetedBrep", engine, if_exists='append', index=False)

### 18. IfcRepresentationContext
context = model.by_type("IfcRepresentationContext")
ContextList = []
for element in context:
    ContextList.append(element.get_info())
df_context = pd.DataFrame.from_dict(ContextList)
df_context['WorldCoordinateSystem_id'] = df_context['WorldCoordinateSystem'].astype('string').apply(createReference)
df_context['TrueNorth_id'] = df_context['TrueNorth'].astype('string').apply(createReference)
df_context['ParentContext_id'] = df_context['ParentContext'].astype('string').apply(createReference)
df_context.drop(columns=['WorldCoordinateSystem', 'TrueNorth', 'ParentContext'], inplace=True)
df_context.to_sql("IfcRepresentationContext", engine, if_exists='append', index=False)


### 19. IfcSweptAreaSolid
solid = model.by_type("IfcSweptAreaSolid")
SolidList = []
for element in solid:
    SolidList.append(element.get_info())
df_solid = pd.DataFrame.from_dict(SolidList)
df_solid['SweptArea_id'] = df_solid['SweptArea'].astype('string').apply(createReference)
df_solid['Position_id'] = df_solid['Position'].astype('string').apply(createReference)
df_solid['ExtrudedDirection_id'] = df_solid['ExtrudedDirection'].astype('string').apply(createReference)
df_solid.drop(columns=['SweptArea', 'Position', 'ExtrudedDirection'], inplace=True)
df_solid.to_sql("IfcSweptAreaSolid", engine, if_exists='append', index=False)


### 20. IfcRectangleProfileDef
paramprofile = model.by_type("IfcRectangleProfileDef")
ParamProfileList = []
for element in paramprofile:
    ParamProfileList.append(element.get_info())
df_paramprofile = pd.DataFrame.from_dict(ParamProfileList)
df_paramprofile['Position_id'] = df_paramprofile['Position'].astype('string').apply(createReference)
df_paramprofile.drop(columns=['Position'], inplace=True)
df_paramprofile.to_sql("IfcRectangleProfileDef", engine, if_exists='append', index=False)


### 21. IfcArbitraryClosedProfileDef
closedprofile = model.by_type("IfcArbitraryClosedProfileDef")
ClosedProfileList = []
for element in closedprofile:
    ClosedProfileList.append(element.get_info())
df_closedprofile = pd.DataFrame.from_dict(ClosedProfileList)
df_closedprofile['OuterCurve_id'] = df_closedprofile['OuterCurve'].astype('string').apply(createReference)
df_closedprofile.drop(columns=['OuterCurve'], inplace=True)