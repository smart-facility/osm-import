#!/usr/bin/env bash

# Run brew doctor. Identifies any issues that may cause following commands to fail.
# Notably, the make install command relies on /usr/local ownership by local user
brew doctor || { echo "Please fix issues identified by brew doctor." ; exit 1 ; }
brew install postgres postgis osm2pgsql wget
make install
