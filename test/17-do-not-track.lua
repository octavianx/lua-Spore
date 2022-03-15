#!/usr/bin/env lua

require 'Test.Assertion'

plan(6)

if not require_ok 'Spore.Middleware.DoNotTrack' then
    skip_rest "no Spore.Middleware.DoNotTrack"
    os.exit()
end
local mw = require 'Spore.Middleware.DoNotTrack'

local req = require 'Spore.Request'.new({})
is_table( req, "Spore.Request.new" )
is_table( req.headers )
equals( req.headers['x-do-not-track'], nil )

local r = mw.call( {}, req )
equals( req.headers['x-do-not-track'], 1, "x-do-not-track is set" )
equals( r, nil )

