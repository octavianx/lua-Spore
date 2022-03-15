#!/usr/bin/env lua

require 'Test.Assertion'

plan(6)

if not require_ok 'Spore.Middleware.Logging' then
    skip_rest "no Spore.Middleware.Logging"
    os.exit()
end
local mw = require 'Spore.Middleware.Logging'

local req = require 'Spore.Request'.new({ sporex = {} })
is_table( req, "Spore.Request.new" )

local r = mw.call( {}, req )
equals( req.env.sporex.logger, nil, "sporex.logger is not set" )
equals( r, nil )

r = mw.call( { logger = "MyLogger" }, req )
equals( req.env.sporex.logger, "MyLogger", "sporex.logger is set" )
equals( r, nil )
