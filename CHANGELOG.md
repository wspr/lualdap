# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
* Lua 5.3 compatibility
  - Backwards compatibility using Kepler Project's [lua-compat-5.3](https://github.com/keplerproject/lua-compat-5.3/)
* Support specifying a URI in hostname argument to `open_simple()`

### Changed
* Switch to [busted](http://olivinelabs.com/busted/) unit testing framework
* Automate building and running unit tests using [CircleCI](http://circleci.com/)
  - Tests run against [OpenShift's OpenLDAP 2.4.41](https://hub.docker.com/r/openshift/openldap-2441-centos7/) ([source](https://github.com/openshift/openldap/))
* Keep track of unit test coverage using [Codecov](http://codecov.io/)

### Fixed
* C89 compatibility
* Fix two credentials-related segfaults in `open_simple()`

[Unreleased]: https://github.com/lualdap/lualdap/compare/v1.2.3...HEAD
