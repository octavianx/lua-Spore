#!/usr/bin/env lua

require 'Test.Assertion'

plan(14)

if not require_ok 'Spore' then
    BAIL_OUT "no lib"
end

local m = require 'Spore'
is_table( m, "Spore" )
equals( m, package.loaded['Spore'] )

equals( m._NAME, 'Spore', "_NAME" )
matches( m._COPYRIGHT, 'Perrad', "_COPYRIGHT" )
matches( m._DESCRIPTION, 'ReST client', "_DESCRIPTION" )
is_string( m._VERSION, "_VERSION" )
matches( m._VERSION, '^%d%.%d%.%d$' )

m = require 'Spore.Core'
is_table( m, "Spore.Core" )
equals( m, package.loaded['Spore.Core'] )

m = require 'Spore.Protocols'
is_table( m, "Spore.Protocols" )
equals( m, package.loaded['Spore.Protocols'] )

m = require 'Spore.Request'
is_table( m, "Spore.Request" )
equals( m, package.loaded['Spore.Request'] )

