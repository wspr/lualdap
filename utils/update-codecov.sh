#!/bin/sh

set -e

curl \
    --fail\
    --silent \
    --show-error \
    --location \
    --output codecov.sh \
	https://codecov.io/bash

chmod +x codecov.sh
