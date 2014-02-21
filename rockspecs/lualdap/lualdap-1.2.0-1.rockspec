package="lualdap"
version="1.2.0-1"
source = {
   url = "https://github.com/jprjr/lualdap/archive/v1.2.0.tar.gz",
   dir = "lualdap-1.2.0",
}
description = {
   summary = "Simple interface from Lua to an LDAP Client",
   detailed = [[
      Simple interface from Lua to an LDAP client.
   ]],
   homepage = "https://github.com/jprjr/lualdap",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.3"
}
external_dependencies = {
   LDAP = {
      header = "ldap.h",
      library = "ldap",
   }
}
build = {
   type = "builtin",
   modules = {
      lualdap = {
         sources = "src/lualdap.c",
         libdirs = "$(LDAP_LIBDIR)",
         incdirs = "$(LDAP_INCDIR)",
         libraries = "ldap",
      },
   }
}
