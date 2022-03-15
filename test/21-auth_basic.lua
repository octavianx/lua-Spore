#!/usr/bin/env lua

require 'Test.Assertion'

plan(12)

if not require_ok 'Spore.Middleware.Auth.Basic' then
    skip_rest "no Spore.Middleware.Auth.Basic"
    os.exit()
end
local mw = require 'Spore.Middleware.Auth.Basic'

local req = require 'Spore.Request'.new({ spore = {} })
is_table( req, "Spore.Request.new" )
is_table( req.headers )
equals( req.headers['authorization'], nil )

local r = mw.call({}, req)
equals( req.headers['authorization'], nil, "authorization is not set" )
equals( r, nil )

local data = { username = 'john', password = 's3kr3t' }
r = mw.call(data, req)
equals( req.headers['authorization'], nil, "authorization is not set" )
equals( r, nil )

req.env.spore.authentication = true
r = mw.call(data, req)
local auth = req.headers['authorization']
is_string( auth, "authorization is set" )
equals( auth:sub(1, 6), "Basic ", "starts by 'Basic '" )
local unenc = require 'mime'.unb64(auth:sub(7))
equals( unenc, "john:s3kr3t", "john:s3kr3t" )
equals( r, nil )
