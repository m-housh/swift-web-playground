#!/bin/sh

# This is a work in progress experimenting with DocC.  It currently creates documentation for
# all the dependencies as well, so this script reads directory names from Sources/ and
# then copies the relevant archives to another directory.

# change path when ready.
mkdir -p /tmp/docs

find Sources -type d | \
	awk '{ print substr($0, 9) }' | \
	while read line; do if [[ "$line" != "" ]]; \
  # change archive path when ready.
  then echo "/tmp/swift-web-playground-docs/Build/Products/Debug/$line.doccarchive"; fi; done | \
  while read archive; do if [[ -d "$archive" ]]; \
  # change copy path when ready.
  then cp -r "$archive" /tmp/docs && echo "copied $archive"; fi; done
