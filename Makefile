N= LuaLDAP
T= lualdap
V= 1.2.3
CONFIG= ./config

include $(CONFIG)

ifneq ($(filter check,$(MAKECMDGOALS)),)
$(foreach var,LDAP_URI LDAP_BASE_DN LDAP_BIND_DN LDAP_BIND_PASSWORD LDAP_TEST_DN LDAP_TEST_PASSWORD,$(if $(value $(var)),$(info $(var): $(value $(var))),$(error $(var) required when running tests)))
endif

LDAP_HOST= $(patsubst %:389/,%,$(patsubst ldap://%,%,$(LDAP_URI)))

ifeq "$(LUA_VERSION_NUM)" "500"
COMPAT_O= $(COMPAT_DIR)/compat-5.1.o
endif

OBJS= src/lualdap.o $(COMPAT_O)

CPPFLAGS:=$(CPPFLAGS) -DPACKAGE_STRING="\"$N $V\""

src/$(LIBNAME): $(OBJS)
	$(CC) $(CFLAGS) $(LIB_OPTION) -o src/$(LIBNAME) $(OBJS) $(OPENLDAP_LIB)

install: src/$(LIBNAME)
	$(INSTALL) src/$(LIBNAME) $(DESTDIR)$(LUA_LIBDIR)
	ln -f -s $(LIBNAME) $(DESTDIR)$(LUA_LIBDIR)/$T.so

clean:
	$(RM) $(OBJS) src/$(LIBNAME)

check:
	env LUA_CPATH_5_3="src/?.so.$(V)" $(LUA) tests/test.lua $(LDAP_HOST) $(LDAP_BASE_DN) $(LDAP_TEST_DN) $(LDAP_BIND_DN) $(LDAP_BIND_PASSWORD)
