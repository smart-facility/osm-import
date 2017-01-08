#!/usr/bin/env bash


# osm-import/linux_install_dependencies.sh

# Script for installing dependencies on Ubuntu 14.04 LTS
# © 2014-2015 Matthew Berryman

# All rights reserved.

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

sudo apt-get update
sudo make install
sudo apt-get install osm2pgsql postgresql postgis postgresql-9.5-postgis-scripts git build-essential
