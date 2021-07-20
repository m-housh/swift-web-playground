#!/bin/sh
apt-get --fix-missing update
apt-get install -y \
  cmake libpq-dev libssl-dev libz-dev openssl postgresql sudo
  
service postgresql start
sudo -u postgres createuser --superuser playground
sudo -u postgres psql "ALTER USER playground PASSWORD 'playground'"
sudo -u postgres createdb --owner playground playground_test

swift test || exit $?
