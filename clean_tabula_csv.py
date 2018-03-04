#!/usr/bin/env python3

import csv
import sys

for file in sys.argv[1:]:
    with open(file, 'r') as f:
        permit = file.replace("_StreetUsePermit.csv", "")
        reader = csv.reader(f)
        for row in reader:
            for col in row:
                if col.startswith('RW'):
                    if row[1] != "":
                        last_street = row[1]
                    # permit,streetname,from_st,to_st
                    print("%s,%s,%s,%s" % (permit, last_street.replace("\n", " "), row[2].replace("\n", " "), row[3].replace("\n", " ")))
                    continue
