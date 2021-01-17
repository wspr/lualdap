T= lualdap
V= 1.2.5
R= 1
CONFIG= ./config

include $(CONFIG)

ifneq ($(filter check,$(MAKECMDGOALS)),)
include tests/test.env
LDAP_VARS=LDAP_URI LDAP_BASE_DN LDAP_BIND_DN LDAP_BIND_PASSWORD LDAP_TEST_DN LDAP_TEST_PASSWORD
$(foreach var,$(LDAP_VARS),$(if $(value $(var)),$(info $(var): $(value $(var))),$(error $(var) required when running tests)))
LDAP_HOST= $(shell echo "$(LDAP_URI)" | sed -r 's,^.*://([^:/]+).*$$,\1,')
endif

CFLAGS_WARN := -pedantic -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings

override CPPFLAGS := -DLUA_C89_NUMBERS $(CPPFLAGS)
override CFLAGS := -O2 -fPIC -std=c89 $(CFLAGS_WARN) $(CFLAGS)

ifdef BUILD_VARIANT
REPORT_DIR := test-reports/$(BUILD_VARIANT)
else
REPORT_DIR := test-reports
endif

ifdef COVERAGE
override CFLAGS := $(CFLAGS) -O0 -g --coverage
override BUSTEDFLAGS := $(BUSTEDFLAGS) --coverage
endif

ifdef JUNITXML
override BUSTEDFLAGS := $(BUSTEDFLAGS) --output=junit -Xoutput $(REPORT_DIR)/report.xml
endif

OBJS= src/lualdap.o
INCS := -I$(LUA_INCDIR) -I$(LDAP_INCDIR) -I$(LBER_INCDIR)
LIBS := -L$(LDAP_LIBDIR) $(LDAP_LIB) -L$(LBER_LIBDIR) $(LBER_LIB)

override CPPFLAGS := $(INCS) $(CPPFLAGS)
override LDFLAGS := $(LIBFLAG) $(LDFLAGS)

LIBNAME=$(T).so

src/$(LIBNAME): $(OBJS)
	$(CC) $(CFLAGS) -o src/$(LIBNAME) $(LDFLAGS) $(OBJS) $(LIBS)

install: src/$(LIBNAME)
	$(INSTALL) -d $(DESTDIR)$(INST_LIBDIR)
	$(INSTALL) src/$(LIBNAME) $(DESTDIR)$(INST_LIBDIR)

clean:
	$(RM) -r $(OBJS) src/$(LIBNAME) src/*.gcda src/*.gcno src/*.gcov luacov.*.out $(REPORT_DIR)

luacheck:
	luacheck --codes --std min tests/smoke.lua --ignore 113/lualdap
	luacheck --codes --std max+busted --max-line-length 160 -a -u tests/test.lua --ignore 431

smoke:
	@echo SMOKE with $(LUA)
	@LUA_CPATH="./src/?.so" $(LUA) tests/smoke.lua

check: $(REPORT_DIR)
	env $(foreach var,$(LDAP_VARS) LDAP_HOST,$(var)=$($(var))) busted $(BUSTEDFLAGS) tests/test.lua
ifdef COVERAGE
	luacov
	mv luacov.*.out $(REPORT_DIR)
endif

$(REPORT_DIR):
	mkdir -p $@

rock:
	luarocks pack rockspec/lualdap-$(V)-$(R).rockspec

pages:
	mkdocs build

gh-pages:
	mkdocs gh-deploy --clean

deb:
	echo "lua-ldap ($(V)) unstable; urgency=medium" >  debian/changelog
	echo ""                         >> debian/changelog
	echo "  * UNRELEASED"           >> debian/changelog
	echo ""                         >> debian/changelog
	echo " -- $(shell git config --get user.name) <$(shell git config --get user.email)>  $(shell date -R)" >> debian/changelog
	fakeroot debian/rules clean binary
