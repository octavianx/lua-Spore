#!/usr/bin/env lua

Spore = require 'Spore'

require 'Test.Assertion'

plan(29)

error_matches( [[Spore.new_from_string(true)]],
        "bad argument #1 to new_from_string %(string expected, got boolean%)" )

error_matches( [[Spore.new_from_string('', '', true)]],
        "bad argument #3 to new_from_string %(string expected, got boolean%)" )

error_matches( [[Spore.new_from_string('{ BAD }')]],
        "unexpected character", "Invalid JSON data" )

error_matches( [[Spore.new_from_string('{ }', '{ }')]],
        "no method in spec" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
        }
    }
}
]])]=],
        "get_info without field method" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            method : "GET",
        }
    }
}
]])]=],
        "get_info without field path" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
            expected_status : true,
        }
    }
}
]])]=],
        "expected_status of get_info is not an array" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
            required_params : true,
        }
    }
}
]])]=],
        "required_params of get_info is not an array" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
            optional_params : true,
        }
    }
}
]])]=],
        "optional_params of get_info is not an array" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
            "form-data" : true,
        }
    }
}
]])]=],
        "form%-data of get_info is not an hash" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
            headers : true,
        }
    }
}
]])]=],
        "headers of get_info is not an hash" )

error_matches( [=[Spore.new_from_string([[
{
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]])]=],
        "base_url is missing" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]])]=],
        "base_url is invalid" )

error_matches( [=[Spore.new_from_string([[
{
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]], { base_url = 'services.org' })]=],
        "base_url without host" )

error_matches( [=[Spore.new_from_string([[
{
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]], { base_url = '//services.org/restapi/' })]=],
        "base_url without scheme" )

error_matches( [=[Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]], [[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]])]=],
        "get_info duplicated" )

local client = Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]])
is_table( client )
is_function( client.enable )
is_function( client.reset_middlewares )
is_function( client.get_info )

Spore.methname_modifier = function (name)
    local lowerCamelCase = name:gsub('_(%w)', function (c) return c:upper() end)
    return lowerCamelCase
end
client = Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]])
is_table( client )
is_function( client.enable )
is_function( client.reset_middlewares )
is_function( client.getInfo )
equals( client.get_info, nil )
Spore.methname_modifier = nil


require 'Spore.Protocols'.request = function (req)
    return {
        status = 200,
        body = [[
{
    base_url : "http://services.org/restapi/",
    methods : {
        get_info : {
            path : "/show",
            method : "GET",
        }
    }
}
]],
    }
end -- mock

client = Spore.new_from_spec 'http://local.dummy.org/spec.json'
is_table( client )
is_function( client.enable )
is_function( client.get_info )


require 'Spore.Protocols'.request = function (req)
    return { status = 404 }
end -- mock

error_matches( [[Spore.new_from_spec 'http://local.dummy.org/spec.json']],
        "404 not expected" )
