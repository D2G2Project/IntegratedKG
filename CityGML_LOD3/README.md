### Sample CityGML-LOD3 explration exploration
File used: TUM described in [https://github.com/tum-gis/tum2twin](tum2twin) and provided in a [https://gitlab.lrz.de/tum-gis/tum2twin-datasets/-/tree/main/citygml/lod3-building-datasets](gitlab dataset).
Location: Building in Kaiserslautern, Germany

#### Experiment 1 - Add more building parts to model, doors and windows
Keep ports 7779 (PostgreSQL) and 8084 (Ontop) free.
```
sudo docker-compose -f docker-compose.lod3.yml up
```