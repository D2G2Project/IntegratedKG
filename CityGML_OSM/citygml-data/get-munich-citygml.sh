#!/bin/bash

for LONG in `seq 690 2 690`
do
	for LAT in `seq 5334 2 5334`
	do
		 wget "https://download1.bayernwolke.de/a/lod2/citygml/${LONG}_${LAT}.gml"
	done
done
