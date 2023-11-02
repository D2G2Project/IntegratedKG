import fiona
from shapely.geometry import shape, mapping, Polygon
from lxml import etree
import geopandas as gpd
import pandas as pd
import os
import sqlalchemy

def gml_2_shp (gml_file_path,crs_gml,output_path):
    with fiona.open(output_path, 'w', 'ESRI Shapefile',crs=crs_gml, schema={'geometry': 'Polygon','properties': [('id', 'str')]}) as output:
        tree  = etree.parse(gml_file_path)
        namespaces = {k: v for k, v in tree.getroot().nsmap.items() if k}
        elements = tree.xpath('//bldg:GroundSurface', namespaces=namespaces)
        for element in elements:
            gml_id = element.get('{http://www.opengis.net/gml}id')
            pos_list  = element.find('.//gml:posList', namespaces=namespaces)
            if pos_list is not None:
                pos_list_str = pos_list.text.strip().split()
                coords = [(float(pos_list_str[i]), float(pos_list_str[i+1]), float(pos_list_str[i+2])) for i in range(0, len(pos_list_str), 3)]
                polygon = Polygon(coords)
                feature = {'geometry': mapping(polygon), 'properties': {'id': gml_id}}
                output.write(feature)

def spatial_join(osm_file_path,gml_file_path,uni_crs,tolerance,output_path):
    tolerance = str(tolerance)
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    
    # Read in the shapefiles
    osm_data = gpd.read_file(osm_file_path)
    gml_data = gpd.read_file(gml_file_path)
    
    # remove OSM non-buildings 
    osm_data = osm_data[osm_data.building != 'NULL']
    
    osm_data = osm_data.to_crs(uni_crs)
    gml_data = gml_data.to_crs(uni_crs)
    
    # obtaining neighbour features
    osm_data["neigh_osm"] = None
    gml_data["neigh_gml"] = None
    for index, idem in gml_data.iterrows():   
        neighbors = gml_data[~gml_data.geometry.disjoint(idem.geometry)].id.tolist()
        neighbors = [ name for name in neighbors if idem.id != name ]
        gml_data.at[index, "neigh_gml"] = ",".join(neighbors)
    for index, idem in osm_data.iterrows():   
        neighbors = osm_data[~osm_data.geometry.disjoint(idem.geometry)].full_id.tolist()
        neighbors = [ name for name in neighbors if idem.full_id != name ]
        osm_data.at[index, "neigh_osm"] = ",".join(neighbors)
        
    # matching
    osm_data['osm_area']= osm_data.area
    gml_data['gml_area']= gml_data.area
    merged = osm_data.overlay(gml_data, how='intersection')
    merged['overlap_area'] = merged.area
    merged['ratio_overlap_osm'] = merged['overlap_area'] / merged['osm_area']
    merged['ratio_overlap_gml'] = merged['overlap_area'] / merged['gml_area']
    matched = merged.query(('ratio_overlap_osm > '+tolerance +  'or ratio_overlap_gml > '+tolerance))
    
    # obtain not matched buildings
    osm_left = pd.concat([osm_data['full_id'],matched['full_id'],matched['full_id']]).drop_duplicates(keep=False)
    gml_left = pd.concat([gml_data['id'],matched['id'],matched['id']]).drop_duplicates(keep=False)
    _1_0 = len(osm_left)
    _0_1 = len(gml_left)
    
    count_osm_con = {} # count of matched id
    count_gml_con = {}
    dict_osm_con = {} # matched ids
    dict_gml_con = {}
    dict_osm_neigh = {}# neighbour ids
    dict_gml_neigh = {}

    for i in range(matched.shape[0]):
        tmp_osm_id = matched.iloc[i].full_id
        tmp_gml_id = matched.iloc[i].id
        neigh_osm = matched.iloc[i].neigh_osm.split(',')
        neigh_gml = matched.iloc[i].neigh_gml.split(',')

        if tmp_osm_id in dict_osm_con:
            dict_osm_con[tmp_osm_id].append(tmp_gml_id)
            count_osm_con[tmp_osm_id] = count_osm_con[tmp_osm_id] + 1
            dict_gml_neigh[tmp_osm_id].extend(neigh_gml)
        else:
            dict_osm_con[tmp_osm_id] = [tmp_gml_id]
            count_osm_con[tmp_osm_id] = 1
            dict_gml_neigh[tmp_osm_id] = neigh_gml

        if tmp_gml_id in dict_gml_con:
            dict_gml_con[tmp_gml_id].append(tmp_osm_id)
            count_gml_con[tmp_gml_id] = count_gml_con[tmp_gml_id] + 1
            dict_osm_neigh[tmp_gml_id].extend(neigh_osm)
        else:
            dict_gml_con[tmp_gml_id] = [tmp_osm_id]
            count_gml_con[tmp_gml_id] = 1
            dict_osm_neigh[tmp_gml_id] = neigh_osm

    # organizing the neighbour features
    for key in dict_osm_neigh:
        dict_osm_neigh[key] = list(dict.fromkeys(dict_osm_neigh[key]))
        for osm in dict_osm_neigh[key].copy():
            if osm in count_osm_con:
                dict_osm_neigh[key].remove(osm)
    for key in dict_gml_neigh:
        dict_gml_neigh[key] = list(dict.fromkeys(dict_gml_neigh[key]))
        for gml in dict_gml_neigh[key].copy():
            if gml in count_gml_con:
                dict_gml_neigh[key].remove(gml)        
    
    # statistic the matching relationship
    _1_1 = 0
    osm_m_1 = 0
    osm_1_n = 0
    osm_m_n = 0

    for osm_feature in count_osm_con.keys():
        if count_osm_con[osm_feature] == 1:
            if count_gml_con[dict_osm_con[osm_feature][0]] == 1:
                _1_1 = _1_1 + 1
            else:
                osm_m_1 = osm_m_1 + 1
        else:
            flag = False  #  to identify whether all of the mathced_gml have 1 connection
            for matched_gml_feature in dict_osm_con[osm_feature]:
                if count_gml_con[matched_gml_feature] != 1:
                    osm_m_n = osm_m_n +1
                    flag = True
                    break
            if flag == False:
                osm_1_n = osm_1_n +1
    
    # saving index tables
    index_gml = pd.DataFrame.from_dict(dict_gml_con,orient='index')
    index_gml.rename(columns=lambda x: 'matched_' + str(x), inplace=True)
    index_gml2 = pd.DataFrame.from_dict(count_gml_con,orient='index')
    index_gml2.columns=['count_matched']
    index_gml3 = pd.DataFrame.from_dict(dict_osm_neigh,orient='index')
    index_gml3.rename(columns=lambda x: 'adjacent_' + str(x), inplace=True)
    index_gml = pd.concat([index_gml2,index_gml,index_gml3],sort = False, axis = 1)
    index_gml = index_gml.reset_index()

    index_osm = pd.DataFrame.from_dict(dict_osm_con,orient='index')
    index_osm.rename(columns=lambda x: 'matched_' + str(x), inplace=True)
    index_osm2 = pd.DataFrame.from_dict(count_osm_con,orient='index')
    index_osm2.columns=['count_matched']
    index_osm3 = pd.DataFrame.from_dict(dict_gml_neigh,orient='index')
    index_osm3.rename(columns=lambda x: 'adjacent_' + str(x), inplace=True)
    index_osm = pd.concat([index_osm2,index_osm,index_osm3],sort = False, axis = 1)
    index_osm = index_osm.reset_index()

    list1 = [index_gml, index_osm]
    return list1

# Return df-s tracking only citygml_id, osm_id and association_type
def reshape_data_tables(df, base_colname, target_colname):
    df.drop(columns="count_matched", inplace=True)
    df_matched = df.loc[:,~df.columns.str.startswith('adjacent')]\
        .set_index('index').stack().droplevel(1).rename(target_colname).reset_index()
    df_adjacent = df.loc[:,~df.columns.str.startswith('matched')]\
        .set_index('index').stack().droplevel(1).rename(target_colname).reset_index()
    df_matched['association_type'] = "matched"
    df_adjacent['association_type'] = "adjacent"
    df_final = pd.concat([
        df_matched[df_matched[target_colname] != ""],
        df_adjacent[df_adjacent[target_colname] != ""]])
    df_final.rename(columns={"index": base_colname}, inplace=True)
    return df_final

def push_linkage_table(list):
    # Format citygml df to have only id-s in 2 cols
    df1 = reshape_data_tables(list[0], "associated_citygmlid", "associated_osmid")
    # Format osm df to have only id-s in 2 cols
    df2 = reshape_data_tables(list[1], "associated_osmid", "associated_citygmlid")

    df2_reordered = df2[['associated_citygmlid' , 'associated_osmid', 'association_type']]

    # Append tables
    result = pd.concat([df1, df2_reordered])
    result.drop_duplicates(inplace=True)

    # Add id as PK
    result.insert(0, 'id', range(1, 1 + len(result)))

    # Reformat osm to add FK as needed
    result['osm_type'] = result['associated_osmid'].str[0]
    result['associated_osmid'] = result['associated_osmid'].str[1:]

    # Set slqalchemy engine for connection to PostgreSQL
    db_iri = f'postgresql://citydb:citydb@host.docker.internal:7778/citydb'
    engine = sqlalchemy.create_engine(db_iri)

    # Push to database; keep index as id for new class
    result.to_sql("citygml_osm_association", engine, if_exists='append', index=False)

if __name__ == '__main__':
    gml_file_path = './data/690_5334.gml'
    crs_gml = 'epsg:25832'  # the original CRS of GML data
    output_gml_shp = '690_5334_gml.shp'
    gml_2_shp(gml_file_path,crs_gml,output_gml_shp)

    gml_shp_path = output_gml_shp
    uni_crs = 'epsg:25832'  # project the CRSs of the two data into this one CRS
    osm_file_path = './data/690_5334_OSM.shp'
    output_path = '.'
    tolerance = 0.5 # match when (ratio of the overlap area) > tolerance

    # Get list of citygml and osm dataframes with linkages
    list = spatial_join(osm_file_path,gml_shp_path, uni_crs,tolerance,output_path)
    # Push to pgsql
    push_linkage_table(list)