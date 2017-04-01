#!/bin/sh

set -e

version="$1"
test -n "$version" || exit 1

curl \
	--fail\
	--silent \
	--show-error \
	--location \
	--output circleci-matrix.sh \
	https://github.com/michaelcontento/circleci-matrix/raw/master/src/circleci-matrix.sh

chmod +x circleci-matrix.sh
