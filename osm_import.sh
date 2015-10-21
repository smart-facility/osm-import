#!/usr/local/bin/bash

# osm-import/osm_import.sh

# Script for preparing an openstreetmap database under OS X + homebrew / Ubuntu 14.04 LTS
# © 2014-2015 Matthew Berryman

# All rights reserved.

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

rm osm.sql.bz2 # remove the old compressed version. We do some steps later to transfer the db to a new host.
curl -O http://download.geofabrik.de/australia-oceania-latest.osm.bz2
curl -O http://download.geofabrik.de/asia/indonesia-latest.osm.bz2
curl -O http://download.geofabrik.de/asia/china-latest.osm.bz2
pbunzip2 *.bz2

createdb -E utf8 osm

OS=`uname -s`

if [ $OS == "Linux" ];
  then POSTGIS_PATH=/usr/share/postgresql/9.3/contrib/postgis-2.1
elif [ $OS == "Darwin" ];
  then POSTGIS_PATH=/usr/local/share/postgis
else echo "Operating system unknown"
  exit 1
fi

# Following path is for OS X / homebrew.
# For Ubuntu 14.04 LTS change /usr/local/share to /usr/share/postgresql/9.3/contrib/postgis-2.1

psql -d osm -f $POSTGIS_PATH/postgis.sql
psql -d osm -f $POSTGIS_PATH/spatial_ref_sys.sql
psql -d osm -f $POSTGIS_PATH/legacy.sql
psql -d osm -f $POSTGIS_PATH/legacy_gist.sql

# Directly importing individuall using osm2pgsql started failing because of some overlap between indonesia and china in newer cuts of the planet file.
# osmconvert works around that
osmconvert australia-oceania-latest.osm indonesia-latest.osm china-latest.osm -o=all.osm

osm2pgsql -H localhost -p osm -d osm -m -E 3857 -C 4096 all.osm
# Note that any subsequent files need the -a option, to append them in.
# You may need to tweak the cache size with the -C option (in MB), the default being too small to process the Asia .pbf file, for example.
#osm2pgsql -H localhost -p osm -d osm -m -E 3857 -C 4096 -a indonesia-latest.osm.pbf
#osm2pgsql -H localhost -p osm -d osm -m -E 3857 -C 4096 -a china-latest.osm.pbf

psql -d osm -f basemaps/contrib/osm2pgsql-to-imposm-schema.sql

# These lines I include as I want to host this database on a separate machine from the one I run this script on:
pg_dump -O -b -f osm.sql osm
pbzip2 -9 osm.sql

# Clean up the .pbf files so that the latest versions are downloaded next time.
# I turn this off and comment out the wget lines when I want to debug the rest to save on downloads and time.
rm *.osm
# Database is no longer needed (we transfer it across to a different box) - you may want to comment this out.
dropdb osm
