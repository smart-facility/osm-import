#!/usr/bin/env bash

# Run brew doctor. Identifies any issues that may cause following commands to fail.
# Notably, the make install command relies on /usr/local ownership by local user
sudo apt-get update
sudo apt-get install osm2pgsql postgresql postgis postgresql-9.3-postgis-scripts git
sudo make install
sudo apt-get install osm2pgsql postgresql postgis postgresql-9.3-postgis-scripts git build-essential libz-dev
