#!/usr/bin/env lua5.1
---------------------------------------------------------------------
-- LuaLDAP test file.
-- This test will create a copy of an existing entry on the
-- directory to work on.  This new entry will be modified,
-- renamed and deleted at the end.
--
-- See Copyright Notice in license.html
-- $Id: test.lua,v 1.15 2006-07-24 01:36:51 tomas Exp $
---------------------------------------------------------------------

local getenv = require("os").getenv
local unpack = assert(require("table")).unpack or unpack

local assert = assert(require("luassert"))
local say = assert(require("say"))

local lualdap = assert(require("lualdap"))

local URI = assert(getenv("LDAP_URI"))
local HOSTNAME = assert(getenv("LDAP_HOST"))
local BASE = assert(getenv("LDAP_BASE_DN"))
local WHO = assert(getenv("LDAP_TEST_DN"))
local BIND_DN = assert(getenv("LDAP_BIND_DN"))
local PASSWORD = assert(getenv("LDAP_BIND_PASSWORD"))

local function set_failure_message(state, message)
	if message ~= nil then
		state.failure_message = message
	end
end

local function returned_future(state, arguments, level)
	local expected_return_value = arguments[1]
	local f = arguments[2]
	local ok, future = pcall(f, unpack(arguments, 3))
	if not ok then
		set_failure_message(state, "Call was not successful: "..tostring(future))
		return false
	elseif type(future) ~= "function" then
		set_failure_message(state, "Call did not return a function: "..type(future))
		return false
	else
		local return_value = future()
		if return_value ~= expected_return_value then
			set_failure_message(state, "Future did not return expected value (expected: "..tostring(expected_return_value)..", got: "..tostring(return_value)..")")
			return false
		end
	end

	return true
end

say:set_namespace("en")
say:set("assertion.returned_future.positive", "Expected call to return a future %s:\n%s")
say:set("assertion.returned_future.negative", "Expected call not to return a future %s:\n%s")
assert:register("assertion", "returned_future", returned_future, "assertion.returned_future.positive", "assertion.returned_future.negative")

--
local DN_PAT = "^([^,=]+)%=([^,]+)%,?(.*)$"

---------------------------------------------------------------------
-- Print attributes.
---------------------------------------------------------------------
function print_attrs (dn, attrs)
	if not dn then
		io.write ("nil\n")
		return
	end
	io.write (string.format ("\t[%s]\n", dn))
	for name, values in pairs (attrs) do
		io.write ("["..name.."] : ")
		local tv = type (values)
		if tv == "string" then
			io.write (values)
		elseif tv == "table" then
			local n = #values
			for i = 1, n-1 do
				io.write (values[i]..",")
			end
			io.write (values[n])
		end
		io.write ("\n")
	end
end

---------------------------------------------------------------------
-- clone a table.
---------------------------------------------------------------------
function clone (tab)
	local new = {}
	for i, v in pairs (tab) do
		new[i] = v
	end
	return new
end


---------------------------------------------------------------------
-- object test.
---------------------------------------------------------------------
function test_object (obj, objmethods)
	-- checking object type.
	it("is a userdata object", function()
		assert.is_userdata(obj)
	end)
	-- trying to get metatable.
	it("is not permitted to access the object's metatable", function()
		assert.is_same("LuaLDAP: you're not allowed to get this metatable",
			getmetatable(obj))
	end)
	-- trying to set metatable.
	assert.is_false(pcall(setmetatable, ENV, {}))
	-- checking existence of object's methods.
	for i = 1, #objmethods do
		local method = obj[objmethods[i]]
		it(objmethods[i].."is a function", function()
			assert.is_function(method)
		end)
		it("is not acceptable to call the "..objmethods[i].." without 'self'", function()
			assert.is_false(pcall(method))
		end)
	end
	return obj
end

CONN_OK = function (obj, err)
	if obj == nil then
		error (err, 2)
	end
	return test_object (obj, { "close", "add", "compare", "delete", "modify", "rename", "search", })
end

---------------------------------------------------------------------
-- basic checking test.
---------------------------------------------------------------------
describe("basics", function()
	local ld = CONN_OK (lualdap.open_simple (HOSTNAME, BIND_DN, PASSWORD))
	it("can close connection", function()
		assert.is_same(1, ld:close())
	end)
	-- trying to close without a connection.
	assert.is_false(pcall(ld.close))
	-- trying to close an invalid connection.
	assert.is_false(pcall(ld.close, io.output()))
	-- trying to use a closed connection.
	local _,_,rdn_name,rdn_value = string.find (BASE, DN_PAT)
	it("is not permitted to use a closed connection", function()
		assert.is_false(pcall(ld.compare, ld, BASE, rdn_name, rdn_value))
	end)
	it("is ok to close a closed object, but nil is returned instead of 1", function()
		assert.is_nil(ld:close())
	end)
	it("is an error to connect to an invalid host", function()
		assert.is_nil(lualdap.open_simple ("unknown-server"))
	end)
end)
describe("creating a connection using a URI", function()
	local ld = CONN_OK (lualdap.open_simple (URI, BIND_DN, PASSWORD))
	it("can close connection", function()
		assert.is_same(1, ld:close())
	end)
end)

describe("tests on an existing connection", function()
	local LD, NEW_DN, DN, ENTRY

	-- reopen the connection.
	setup(function()
		-- first, try using TLS
		local ok, err = lualdap.open_simple (HOSTNAME, BIND_DN, PASSWORD, true)
		if not ok then
			ok, err = lualdap.open_simple (HOSTNAME, BIND_DN, PASSWORD, false)
		end
		LD = assert(ok, err)
		CLOSED_LD = ld
		collectgarbage()
	end)

---------------------------------------------------------------------
-- checking compare operation.
---------------------------------------------------------------------
describe("compare operation", function()
	local _,_,rdn_name,rdn_value = string.find (BASE, DN_PAT)
	assert.message("could not extract RDN name").is_string(rdn_name)
	assert.message("could not extract RDN value").is_string(rdn_value)
	-- comparing against the correct value.
	it(rdn_name.." = "..rdn_value.." should be true", function()
		assert.returned_future(true, LD.compare, LD, BASE, rdn_name, rdn_value)
	end)
	-- comparing against a wrong value.
	it(rdn_name.." = "..rdn_value.." should be false", function()
		assert.returned_future(false, LD.compare, LD, BASE, rdn_name, rdn_value..'_')
	end)
	-- comparing against an incorrect attribute name.
	it(rdn_name.." = "..rdn_value.." should be nil", function()
		assert.returned_future(nil, LD.compare, LD, BASE, rdn_name..'x', rdn_value)
	end)
	-- comparing on a wrong base.
	it("Comparing on a wrong base should be nil", function()
		assert.returned_future(nil, LD.compare, LD, 'qwerty', rdn_name, rdn_value)
	end)
	-- comparing with a closed connection.
	it("Comparing with a closed connection should fail", function()
		assert.is_false(pcall(LD.compare, CLOSED_LD, BASE, rdn_name, rdn_value))
	end)
	-- comparing with an invalid userdata.
	it("Comparing with an invalid connection should fail", function()
		assert.is_false(pcall(LD.compare, io.output(), BASE, rdn_name, rdn_value))
	end)
end)


---------------------------------------------------------------------
-- checking basic search operation.
---------------------------------------------------------------------
describe("basic search operation", function()
	local _,_,rdn = string.find (WHO, "^([^,]+)%,.*$")
	local iter = LD:search {
		base = BASE,
		scope = "onelevel",
		sizelimit = 1,
		filter = "("..rdn..")",
	}
	assert.is_function(iter)
	collectgarbage()
	CONN_OK (LD)
	local dn, entry = iter ()
	assert.is_string(dn)
	assert.is_table(entry)
	collectgarbage()
	assert.is_function(iter)
	CONN_OK (LD)

	DN, ENTRY = LD:search {
		base = BASE,
		scope = "onelevel",
		sizelimit = 1,
		filter = "("..rdn..")",
	}()
	collectgarbage()
	assert.is_string(DN)
	assert.is_table(ENTRY)
end)


---------------------------------------------------------------------
-- checking add operation.
---------------------------------------------------------------------
describe("add operation", function()
	-- clone an entry.
	local NEW = clone (ENTRY)
	local _,_,rdn_name, rdn_value, parent_dn = string.find (DN, DN_PAT)
	NEW[rdn_name] = rdn_value.."_copy"
	NEW_DN = string.format ("%s=%s,%s", rdn_name, NEW[rdn_name], parent_dn)
	-- trying to insert an entry with a wrong connection.
	assert.is_false(pcall(LD.add, CLOSED_LD, NEW_DN, NEW))
	-- trying to insert an entry with an invalid connection.
	assert.is_false(pcall(LD.add, io.output(), NEW_DN, NEW))
	-- trying to insert an entry with a wrong DN.
	local wrong_dn = string.format ("%s_x=%s,%s", rdn_name, NEW_DN, parent_dn)
	--assert2 (nil, LD:add (wrong_dn, NEW))
	assert.returned_future (nil, LD.add, LD, wrong_dn, NEW)
	-- trying to insert the clone on the LDAP data base.
	assert.returned_future(true, LD.add, LD, NEW_DN, NEW)
	-- trying to reinsert the clone entry on the directory.
	assert.returned_future(nil, LD.add, LD, NEW_DN, NEW)
end)


---------------------------------------------------------------------
-- checking modify operation.
---------------------------------------------------------------------
describe("modify operation", function()
	-- modifying without connection.
	assert.is_false(pcall (LD.modify, nil, NEW_DN, {}))
	-- modifying with a closed connection.
	assert.is_false(pcall (LD.modify, CLOSED_LD, NEW_DN, {}))
	-- modifying with an invalid userdata.
	assert.is_false(pcall (LD.modify, io.output(), NEW_DN, {}))
	-- checking invalid DN.
	assert.is_false(pcall (LD.modify, LD, {}))
	-- no modification to apply.
	assert.returned_future(true, LD.modify, LD, NEW_DN)
	-- forgotten operation on modifications table.
	local a_attr, a_value = next (ENTRY)
	assert.is_false(pcall (LD.modify, LD, NEW_DN, { [a_attr] = "abc"}))
	-- modifying an unknown entry.
	local _,_, rdn_name, rdn_value, parent_dn = string.find (NEW_DN, DN_PAT)
	local new_rdn = rdn_name..'='..rdn_value..'_'
	local new_dn = string.format ("%s,%s", new_rdn, parent_dn)
	assert.returned_future(nil, LD.modify, LD, new_dn)
	-- trying to create an undefined attribute.
	assert.returned_future(nil, LD.modify, LD, NEW_DN, {'+', unknown_attribute = 'a'})
end)


---------------------------------------------------------------------
function count (tab)
	local counter = 0
	for dn, entry in LD:search (tab) do
		counter = counter + 1
	end
	return counter
end


---------------------------------------------------------------------
-- checking advanced search operation.
---------------------------------------------------------------------
describe("advanced search operation", function()
	local _,_,rdn = string.find (WHO, "^([^,]+)%,.*$")
	local iter = LD:search {
		base = BASE,
		scope = "onelevel",
		sizelimit = 1,
		filter = "("..rdn..")",
	}
	assert.is_function(iter)
	collectgarbage ()
	assert.is_function(iter)
	local dn, entry = iter ()
	assert.is_string(dn)
	assert.is_table(entry)
	collectgarbage ()
	assert.is_function(iter)
	iter = nil
	collectgarbage ()

	-- checking no search specification.
	assert.is_false(pcall (LD.search, LD))
	-- checking invalid scope.
	assert.is_false(pcall (LD.search, LD, { scope = 'BASE', base = BASE, }))
	-- checking invalid base.
	assert.returned_future(nil, LD.search, LD, { base = "invalid", scope = "base", })
	-- checking filter.
	local _,_, rdn_name, rdn_value, parent_dn = string.find (NEW_DN, DN_PAT)
	local filter = string.format ("(%s=%s)", rdn_name, rdn_value)
	assert.is_same(1, count { base = BASE, scope = "subtree", filter = filter, })
	-- checking sizelimit.
	assert.is_same(1, count { base = BASE, scope = "subtree", sizelimit = 1, })
	-- checking attrsonly parameter.
	for dn, entry in LD:search { base = BASE, scope = "subtree", attrsonly = true, } do
		for attr, value in pairs (entry) do
			assert.message("attrsonly failed").is_true(value)
		end
	end
	-- checking reuse of search object.
	local iter = assert.is_not_nil(LD:search { base = BASE, scope = "base", })
	assert.is_function(iter)
	local dn, e1 = iter()
	assert.is_string(dn)
	assert.is_table(e1)
	dn, e1 = iter()
	assert.is_nil(dn)
	assert.is_nil(e1)
	assert.is_false(pcall(iter))
	iter = nil
	-- checking collecting search objects.
	local dn, entry = LD:search { base = BASE, scope = "base" }()
	collectgarbage()
end)


---------------------------------------------------------------------
-- checking rename operation.
---------------------------------------------------------------------
describe("rename operation", function()
	local _,_, rdn_name, rdn_value, parent_dn = string.find (NEW_DN, DN_PAT)
	local new_rdn = rdn_name..'='..rdn_value..'_'
	local new_dn = string.format ("%s,%s", new_rdn, parent_dn)
	-- trying to rename with no parent.
	assert.returned_future(true, LD.rename, LD, NEW_DN, new_rdn, nil)
	-- trying to rename an invalid dn.
	assert.returned_future(nil, LD.rename, LD, NEW_DN, new_rdn, nil)
	-- trying to rename with the same parent.
	assert.returned_future(true, LD.rename, LD, new_dn, rdn_name..'='..rdn_value, parent_dn)
	-- trying to rename to an inexistent parent.
	assert.returned_future(nil, LD.rename, LD, NEW_DN, new_rdn, new_dn)
	-- mal-formed DN.
	assert.is_false(pcall (LD.rename, LD, ""))
	-- trying to rename with a closed connection.
	assert.is_false(pcall (LD.rename, CLOSED_LD, NEW_DN, new_rdn, nil))
	-- trying to rename with an invalid connection.
	assert.is_false(pcall (LD.rename, io.output(), NEW_DN, new_rdn, nil))
end)


---------------------------------------------------------------------
-- checking delete operation.
---------------------------------------------------------------------
describe("delete operation", function()
	-- trying to delete with a closed connection.
	assert.is_false(pcall (LD.delete, CLOSED_LD, NEW_DN))
	-- trying to delete with an invalid connection.
	assert.is_false(pcall (LD.delete, io.output(), NEW_DN))
	-- trying to delete new entry.
	it("deleting new entry", function()
		assert.returned_future(true, LD.delete, LD, NEW_DN)
	end)
	-- trying to delete an already deleted entry.
	it("deleting an already deleted entry", function()
		assert.returned_future(nil, LD.delete, LD, NEW_DN)
	end)
	-- mal-formed DN.
	it("deleting a mal-formed DN", function()
		assert.returned_future(nil, LD.delete, LD, "")
	end)
	-- no DN.
	it("deleting a nil DN", function()
		assert.is_false(pcall(LD.delete, LD))
	end)
end)


---------------------------------------------------------------------
-- checking close operation.
---------------------------------------------------------------------
describe("close operation", function()
	assert.message("couldn't close connection").is_same(1, LD:close())
end)

end)
