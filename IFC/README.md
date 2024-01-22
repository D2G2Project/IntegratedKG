### Sample IFC exploration
File used: AC20-FZK-Haus.ifc at http://smartlab1.elis.ugent.be:8889/IFC-repo/.
Location: Building in Kaiserslautern, Germany

#### Experiment 1 - Ontop with sql database via ifcopenshell
Keep ports 7778 (PostgreSQL) and 8083 (Ontop) free.
```
sudo docker-compose -f docker-compose.ifc.yml up
```
Examples focus on IfcSite targeting a few small experiments to retriev site elevation and coordinates.

Scalability of solution not analyzed.