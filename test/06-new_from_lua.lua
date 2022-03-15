#!/usr/bin/env lua

Spore = require 'Spore'

require 'Test.Assertion'

plan(6)

error_matches( [[Spore.new_from_lua(true)]],
        "bad argument #1 to new_from_lua %(table expected, got boolean%)" )

error_matches( [[Spore.new_from_lua({}, true)]],
        "bad argument #2 to new_from_lua %(table expected, got boolean%)" )

local client = Spore.new_from_lua{
    base_url = 'http://services.org/restapi/',
    methods = {
        get_info = {
            path = '/show',
            method = 'GET',
        },
    },
}
is_table( client )
is_function( client.enable )
is_function( client.reset_middlewares )
is_function( client.get_info )

