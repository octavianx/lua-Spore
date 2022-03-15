#!/usr/bin/env lua

require 'Test.Assertion'

plan(6)

if not require_ok 'Spore.Middleware.Runtime' then
    skip_rest "no Spore.Middleware.Runtime"
    os.exit()
end
local mw = require 'Spore.Middleware.Runtime'

local req = require 'Spore.Request'.new({})
is_table( req, "Spore.Request.new" )

local cb = mw.call( {}, req )
is_function( cb )

local n = 1000000
if package.loaded['luacov'] then
    n = n / 200
end
for _ = 1, n do --[[no op]] end
local res = { headers = {} }
equals( res, cb(res) )
local header = res.headers['x-spore-runtime']
is_string( header )
diag(header)
local val = tonumber(header)
truthy( val > 0 )
