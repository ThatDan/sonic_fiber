#!/bin/bash

PERMITS=permits.csv

# Create directories
xsv select -n 3,5 $PERMITS |tail -n +2 |sort -u |tr ',' '/' |xargs mkdir -p

# Download permits
cat $PERMITS | xsv select -n 2,3,5 |tail -n +2 | tr ',' '\n' | parallel -N 3 -j 6 wget -nc -O {2}/{3}/{1}.pdf http://bsm.sfdpw.org/permitstrackertest/PrintPermit.aspx?permit={1}

# Dump CSV
find . -type d -depth 2 | parallel java -jar tabula-1.0.1-jar-with-dependencies.jar -b {} -l -p all  -l -u


echo "permit,streetname,from_st,to_st" > ../sonic_intersections.csv
find . -depth 3 -name '*.csv' -not -name '17TOC-3140.csv' |xargs python3 ../clean_tabula_csv.py  |sed -e 's/^\..*\/.*\/\(.*\)\.csv/\1/' |sed -e 's/COLLINGWO OD/COLLINGWOOD/' >> ../sonic_intersections.csv

(
  cd ..

  rm sonic.sqlite;
  echo "
  .separator ','
  .import sonic_intersections.csv sonic_intersections
  .import List_of_Streets_and_Intersections.csv sf_intersections
  .import San_Francisco_Basemap_Street_Centerlines.csv sf_cnn
  " | sqlite3 sonic.sqlite

  echo "
  SELECT sf_cnn.cnn, sonic.permit, sonic.streetname, sonic.from_st, sonic.to_st, sf_cnn.geometry
  FROM sonic_intersections sonic
  LEFT JOIN sf_intersections sf
    ON sonic.streetname = sf.streetname
    AND sonic.from_st = sf.from_st
    AND sonic.to_st = sf.to_st
  LEFT JOIN sf_cnn
    ON sf.cnn = sf_cnn.cnn;
  " | sqlite3 sonic.sqlite > sonic_fiber.csv
)

