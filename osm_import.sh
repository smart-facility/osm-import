#!/usr/local/bin/bash

# Script for preparing an openstreetmap database under OS X + homebrew / Ubuntu 14.04 LTS
# © 2014, Matthew Berryman

# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the organization nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Dependency installation using homebrew under OS X:
# brew install postgres postgis osm2pgsql wget
# wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert && mv osmconvert /usr/local/bin
# git clone https://github.com/mapserver/basemaps ../basemaps

# Dependency installation for Ubuntu 14.04 LTS:
# sudo apt-get install osm2pgsql postgresql postgis postgresql-9.3-postgis-scripts git wget
# wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert && sudo mv osmconvert /usr/local/bin
# git clone https://github.com/mapserver/basemaps ../basemaps

# See http://download.geofabrik.de for a list of links for subregions (or click on the subregion name for individual country download links).
# Make sure you get the (smaller) .osm.pbf format file.
# I include the ones I use here for example.

rm osm.sql.bz2 # remove the old compressed version. We do some steps later to transfer the db to a new host.
curl -O http://download.geofabrik.de/australia-oceania-latest.osm.bz2
curl -O http://download.geofabrik.de/asia/indonesia-latest.osm.bz2
curl -O http://download.geofabrik.de/asia/china-latest.osm.bz2
pbunzip2 *.bz2

createdb -E utf8 osm

# Following path is for OS X / homebrew.
# For Ubuntu 14.04 LTS change /usr/local/share to /usr/share/postgresql/9.3/contrib/postgis-2.1

psql -d osm -f /usr/local/share/postgis/postgis.sql
psql -d osm -f /usr/local/share/postgis/spatial_ref_sys.sql
psql -d osm -f /usr/local/share/postgis/legacy.sql
psql -d osm -f /usr/local/share/postgis/legacy_gist.sql

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
bzip2 -9 osm.sql

# Clean up the .pbf files so that the latest versions are downloaded next time.
# I turn this off and comment out the wget lines when I want to debug the rest to save on downloads and time.
rm *.osm
# Database is no longer needed (we transfer it across to a different box) - you may want to comment this out.
dropdb osm
