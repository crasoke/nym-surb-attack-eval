#!/bin/sh
docker-compose rm -f
sudo rm -rf ./data/nyx_volume ./data/bin_volume
docker-compose build
docker-compose up