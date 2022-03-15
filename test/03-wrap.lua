#!/usr/bin/env lua

require 'Test.Assertion'

plan(52)

local status = 200
package.loaded['socket.http'] = {
    request = function (req) return req, status end -- mock
}

local Spore = require 'Spore'

local client = Spore.new_from_spec('./test/api.json', {})

error_matches( function () client:get_info(true) end,
        "bad argument #2 to get_info %(table expected, got boolean%)" )

local res = client:get_info{ 'border'; user = 'john' }
local env = res.request.env
is_table( res )
equals( env.REQUEST_METHOD, 'GET' )
equals( env.SERVER_NAME, 'services.org' )
equals( env.SERVER_PORT, '9999' )
equals( env.PATH_INFO, '/restapi/show' )
matches( env.HTTP_USER_AGENT, '^lua%-Spore' )
is_table( env.spore )
equals( env.spore.url_scheme, 'http' )
equals( env.spore.params.user, 'john' )
equals( env.spore.params.border, 'border' )

error_matches( function () client:get_user_info{} end,
        "payload is required for method get_user_info" )

error_matches( function () client:get_user_info{ payload = 'opaque data' } end,
        "user is required for method get_user_info" )

res = client:get_user_info{ user = 'joe', payload = 'OPAQUE' }
env = res.request.env
equals( env.spore.payload, 'OPAQUE', 'opaque payload' )

res = client:get_info{ user = 'joe' }
env = res.request.env
equals( env.spore.params.user, 'joe' )

error_matches( function () client:get_info{ payload = 'opaque data' } end,
        "payload is not expected for method get_info" )

error_matches( function () client:get_info{ mode = 'raw' } end,
        "mode is not expected for method get_info" )

client = Spore.new_from_spec('./test/api.json', { unattended_params = true })
not_errors( function () client:get_info{ mode = 'raw' } end )

Spore.errors = io.tmpfile()
status = 404
local r, ex = pcall( function ()
    local _ = client:get_user_info{ payload = 'opaque data', user = 'john' }
end)
equals( r, false, "exception" )
equals( tostring(ex), "404 not expected", "404 not expected" )

Spore.errors:seek'set'
local msg = Spore.errors:read '*l'
equals( msg, "GET http://services.org:9999/restapi/show?user=john" )
msg = Spore.errors:read '*l'
equals( msg, "404" )

res = client:action1{ user = 'john' }
env = res.request.env
equals( env.REQUEST_METHOD, 'GET' )
equals( env.SERVER_NAME, 'services.org' )
equals( env.SERVER_PORT, '9999' )
equals( env.PATH_INFO, '/restapi/doit' )
equals( env.QUERY_STRING, 'action=action1&user=john' )
equals( res.request.url, 'http://services.org:9999/restapi/doit?action=action1&user=john' )

client = Spore.new_from_string([[
{
    base_url : "http://services.org/restapi/get_info",
    methods : {
        get_info : {
            path : "",
            method : "GET",
        }
    }
}
]])
is_table( client, "empty path")
res = client:get_info()
env = res.request.env
equals( env.PATH_INFO, '/restapi/get_info' )
falsy( env.QUERY_STRING )
equals( res.request.url, 'http://services.org/restapi/get_info' )

client = Spore.new_from_string([[
{
    "base_url" : "http://services.org:9999/restapi/",
    "methods" : {
        "action" : {
            "path" : "/doit/:prm1",
            "method" : "POST",
            "required_params" : [
                "prm1",
                "prm2"
            ],
            "optional_params" : [
                "prm3",
                "prm4"
            ],
            "payload" : [
                "prm2",
                "prm3"
            ],
        }
    }
}
]])
is_table( client, "payload")
res = client:action{ prm1 = 'action1', prm2 = 2, prm3 = 'val3', prm4 = 'val4' }
env = res.request.env
equals( env.PATH_INFO, '/restapi/doit/action1' )
equals( res.request.url, 'http://services.org:9999/restapi/doit/action1?prm4=val4' )
local spore = env.spore
is_table( spore.payload, 'payload')
equals( spore.payload.prm2, 2 )
equals( spore.payload.prm3, 'val3' )

res = client:action{ prm1 = 'action1', prm2 = 2, payload = 'this OPAQUE payload will be trashed' }
env = res.request.env
equals( res.request.url, 'http://services.org:9999/restapi/doit/action1' )
equals( res.request.headers['content-type'], 'application/x-www-form-urlencoded' )
truthy( res.request.headers['content-length'] )
spore = env.spore
is_table( spore.payload, 'payload')
equals( spore.payload.prm2, 2 )
equals( spore.payload.prm3, nil )

client = Spore.new_from_string([[
{
    "base_url" : "http://services.org:9999/restapi/",
    "methods" : {
        "action" : {
            "path" : "/doit/:prm1",
            "method" : "POST",
            "required_params" : [
                "prm1",
                "prm2"
            ],
            "optional_params" : [
                "prm3",
                "prm4"
            ],
            "form-data" : {
                "form2": "g(:prm2)",
                "form3": "h(:prm3)"
            },
        }
    }
}
]])
is_table( client, "form_data")
res = client:action{ prm1 = 'action1', prm2 = 2, prm3 = 'val3', prm4 = 'val4' }
env = res.request.env
equals( env.PATH_INFO, '/restapi/doit/action1' )
equals( res.request.url, 'http://services.org:9999/restapi/doit/action1?prm4=val4' )
matches( res.request.headers['content-type'], '^multipart/form%-data; boundary=' )
truthy( res.request.headers['content-length'] )
spore = env.spore
is_table( spore.form_data, 'form_data')
equals( spore.form_data.form2, 'g(2)' )
equals( spore.form_data.form3, 'h(val3)' )
