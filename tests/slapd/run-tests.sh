#!/bin/sh

tests/slapd/setup.sh

. tests/slapd/test.env
tests/test.lua
