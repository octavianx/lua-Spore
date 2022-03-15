#!/usr/bin/env lua

require 'Test.Assertion'

plan(8)

if not require_ok 'Spore.Middleware.UserAgent' then
    skip_rest "no Spore.Middleware.UserAgent"
    os.exit()
end
local mw = require 'Spore.Middleware.UserAgent'

local req = require 'Spore.Request'.new({})
is_table( req, "Spore.Request.new" )
is_table( req.headers )
equals( req.headers['user-agent'], nil )

local r = mw.call( {}, req )
equals( req.headers['user-agent'], nil, "user-agent is not set" )
equals( r, nil )

r = mw.call( { useragent = "MyAgent" }, req )
equals( req.headers['user-agent'], "MyAgent", "user-agent is set" )
equals( r, nil )
