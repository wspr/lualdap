
local m = require'lualdap'
assert(type(m) == 'table')
assert(m == package.loaded.lualdap)

assert(m._COPYRIGHT:match'Kepler Project')
assert(m._DESCRIPTION:match'LDAP client')
assert(m._VERSION:match'^LuaLDAP %d%.%d%.%d')

-- luacheck: globals lualdap
if _VERSION == 'Lua 5.1' then
    assert(lualdap == m)
end

if not os.getenv('OS') then
    assert(type(m.initialize) == 'function')
end
assert(type(m.open_simple) == 'function')

print'PASS'
