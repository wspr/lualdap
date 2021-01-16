
local m = require'lualdap'
assert(type(m) == 'table')
assert(m == package.loaded.lualdap)

assert(m._COPYRIGHT:match'Kepler Project')
assert(m._DESCRIPTION:match'LDAP client')
assert(m._VERSION:match'^LuaLDAP %d%.%d%.%d')

assert(type(m.initialize) == 'function')
assert(type(m.open_simple) == 'function')

print'PASS'
