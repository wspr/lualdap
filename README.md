# LuaLDAP

[![CircleCI](https://circleci.com/gh/lualdap/lualdap.svg?style=shield)](https://circleci.com/gh/lualdap/lualdap)
[![codecov](https://codecov.io/gh/lualdap/lualdap/branch/master/graph/badge.svg)](https://codecov.io/gh/lualdap/lualdap)

LuaLDAP is a simple interface from Lua to an LDAP client, in fact it is a bind to
OpenLDAP or to Active Directory Service Interfaces (ADSI).  It enables a Lua program to:

* Connect to an LDAP server;
* Execute any operation (search, add, compare, delete, modify and rename);
* Retrieve entries and references of the search result.

# Installation

Current version is 1.2.5.  It was developed for Lua 5.1, 5.2 and 5.3,
and both OpenLDAP 2.1 or newer and ADSI.

# Source code directory structure

Files in the distribution:

    /doc/us/*.html  -- Documentation
    /src/*			    -- Source files
    /tests/*        -- Test files
    /vc6/*          -- Build files for MS Visual C 6 (deprecated)
    /rockspecs/     -- luarocks build system releases
    Makefile        -- Makefile for Unix systems (deprecated)
    config          -- Configurations to build on Unix systems (deprecated)
    Makefile.win    -- Makefile for Windows systens with MS Visual C 8 (unmaintained)
    config.win      -- Configurations to build on Windows systems (unmaintained)
    README.md       -- This file
    NEWS.md         -- News and release notes
    CONTRIBUTORS.md -- Who contributed what
    LICENSE.md      -- MIT License reference

# License

LuaLDAP is free software and uses the same license as Lua 5.1.

# Contributors

Please see CONTRIBUTORS for contribution information and documentation on original source.
