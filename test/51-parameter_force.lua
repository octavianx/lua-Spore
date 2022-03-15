#!/usr/bin/env lua

require 'Test.Assertion'

plan(6)

if not require_ok 'Spore.Middleware.Parameter.Force' then
    skip_rest "no Spore.Middleware.Parameter.Force"
    os.exit()
end
local mw = require 'Spore.Middleware.Parameter.Force'

equals( require 'Spore'.early_validate, false, "early_validate" )

local req = require 'Spore.Request'.new({ spore = { params = { prm1 = 0 } }})
is_table( req, "Spore.Request.new" )
equals( req.env.spore.params.prm1, 0 )

local _ = mw.call( {
    prm1 = 1,
    prm2 = 2,
}, req )
equals( req.env.spore.params.prm1, 1 )
equals( req.env.spore.params.prm2, 2 )

