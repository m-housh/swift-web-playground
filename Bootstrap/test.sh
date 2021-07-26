#!/bin/sh
apt-get --fix-missing update
apt-get install -y \
  cmake libpq-dev libssl-dev libz-dev openssl postgresql sudo openssl
service postgresql start
sudo -u postgres createuser --superuser playground
sudo -u postgres psql -c "ALTER USER playground PASSWORD 'playground';"
sudo -u postgres createdb --owner playground playground_test
sudo chown "$USER":"$USER" Bootstrap/test.sh
swift test --enable-test-discovery || exit $?
