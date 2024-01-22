# TODO: Update to latest version
FROM stain/jena-fuseki:4.0.0

# Update security file with custom settings
RUN rm shiro.ini
COPY shiro.ini shiro.ini
COPY IFCtoRDF-0.4-shaded.jar IFCtoRDF-0.4-shaded.jar

RUN apt-get update; \
    apt-get install -y --no-install-recommends procps

RUN mkdir -p /fuseki/ontologies/
RUN mkdir -p /fuseki/configuration/

RUN mkdir -p /fuseki
WORKDIR /fuseki

### Disabled reasoning for now
# Add configuration file which specifies inside the ontology name
COPY config.ttl configuration/config.ttl

# Convert IFC to RDF data
RUN java -jar IFCtoRDF-0.4-shaded.jar AC20-FZK-Haus.ifc ifcexample.ttl; sleep 30
RUN sleep 30
# Add ontology
COPY ifcexample.ttl ontologies/ifcexample.ttl