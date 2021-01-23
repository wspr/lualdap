package = 'lualdap'
version = 'dev-2'
source = {
    url = 'git://github.com/lualdap/lualdap',
    branch = 'master',
}
description = {
    summary = "A Lua interface to the OpenLDAP library",
    detailed = [[
       LuaLDAP is a simple interface from Lua to an LDAP client, in
       fact it is a bind to OpenLDAP. It enables a Lua program to
       connect to an LDAP server; execute any operation (search, add,
       compare, delete, modify and rename); retrieve entries and
       references of the search result.
    ]],
    license = 'MIT',
    homepage = 'https://lualdap.github.io/lualdap/',
}
dependencies = {
    'lua >= 5.1'
}
external_dependencies = {
    LDAP = {
        header = 'ldap.h',
        library = 'ldap',
    }
}
build = {
    type = 'builtin',
    modules = {
        lualdap = {
            sources = { 'src/lualdap.c' },
            defines = { 'PACKAGE_STRING=\"LuaLDAP ' .. version .. '\"'},
            libdirs = { '$(LDAP_LIBDIR)' },
            incdirs = { '$(LDAP_INCDIR)' },
            libraries = { 'ldap' },
        },
    },
    copy_directories = { 'docs' },
}
