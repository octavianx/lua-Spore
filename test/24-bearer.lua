#!/usr/bin/env lua

require 'Test.Assertion'

plan(11)

if not require_ok 'Spore.Middleware.Auth.Bearer' then
    skip_rest "no Spore.Middleware.Auth.Bearer"
    os.exit()
end
local mw = require 'Spore.Middleware.Auth.Bearer'

local req = require 'Spore.Request'.new({ spore = {} })
is_table( req, "Spore.Request.new" )
is_table( req.headers )
equals( req.headers['authorization'], nil )

local r = mw.call({}, req)
equals( req.headers['authorization'], nil, "authorization is not set" )
equals( r, nil )

local data = { bearer_token = 'ACCESS_TOKEN' }
r = mw.call(data, req)
equals( req.headers['authorization'], nil, "authorization is not set" )
equals( r, nil )

req.env.spore.authentication = true
r = mw.call(data, req)
local auth = req.headers['authorization']
is_string( auth, "authorization is set" )
equals( auth, "Bearer ACCESS_TOKEN", "Bearer" )
equals( r, nil )
