#!/usr/bin/env bash

# osm-import/osx_install_dependencies.sh

# Script for installing dependencies on OS X with homebrew
# © 2014-2015 Matthew Berryman

# All rights reserved.

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Run brew doctor. Identifies any issues that may cause following commands to fail.
# Notably, the make install command relies on /usr/local ownership by local user
brew update
brew doctor || { echo "Please fix issues identified by brew doctor." ; exit 1 ; }
brew install postgres postgis osm2pgsql libz-dev
