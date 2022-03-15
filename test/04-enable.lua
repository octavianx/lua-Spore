#!/usr/bin/env lua

local Spore = require 'Spore'

require 'Test.Assertion'

plan(13)

local client = Spore.new_from_spec './test/api.json'
equals( #client.middlewares, 0 )

error_matches( function () client:enable_if(true) end,
        "bad argument #2 to enable_if %(function expected, got boolean%)" )

error_matches( function () client:enable_if(function () return true end, true) end,
        "bad argument #3 to enable_if %(string expected, got boolean%)" )

error_matches( function () client:enable_if(function () return true end, 'MyMiddleware', true) end,
        "bad argument #4 to enable_if %(table expected, got boolean%)" )

error_matches( function () client:enable(true) end,
        "bad argument #2 to enable %(string expected, got boolean%)" )

error_matches( function () client:enable('MyMiddleware', true) end,
        "bad argument #3 to enable %(table expected, got boolean%)" )

error_matches( function () client:enable 'Spore.Middleware.Unknown' end,
        "module 'Spore%.Middleware%.Unknown' not found" )

error_matches( function () client:enable 'Unknown' end,
        "module 'Spore%.Middleware%.Unknown' not found" )

package.loaded['Spore.Middleware.Dummy'] = { call = true }

error_matches( function () client:enable 'Dummy' end,
        "Spore%.Middleware%.Dummy without a function call" )

package.loaded['Spore.Middleware.Dummy'] = { call = function () end }

client:enable 'Dummy'
equals( #client.middlewares, 1 )
is_table( client.middlewares[1] )

client:enable_if(function (req) return true end, 'Dummy')
equals( #client.middlewares, 2 )

client:reset_middlewares()
equals( #client.middlewares, 0 )

