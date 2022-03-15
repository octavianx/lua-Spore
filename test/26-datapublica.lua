#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'openssl') then
    skip_all 'no openssl'
end

plan(12)

package.loaded['socket.http'] = {
    request = function (req) return req, 200, {} end -- mock
}

if not require_ok 'Spore.Middleware.Auth.DataPublica' then
    skip_rest "no Spore.Middleware.Auth.DataPublica"
    os.exit()
end
local mw = require 'Spore.Middleware.Auth.DataPublica'

local req = require 'Spore.Request'.new({
    SERVER_NAME = 'services.org',
    PATH_INFO = '/path',
    spore = {
        caller = 'fake',
        url_scheme = 'http',
        method = {
            unattended_params = true,
        },
        params = {},
    }
})
is_table( req, "Spore.Request.new" )
is_table( req.headers )

local r = mw.call({}, req)
equals( r, nil )

local data = {
    key      = '356a192c7813b04c54574d18c28d46e6395428ab',
    password = '30d87add92e7b27ce4',
}
r = mw.call(data, req)
equals( r, nil )

req.env.spore.authentication = true
r = mw.call(data, req)
equals( r.status, 200 )
matches( r.request.url, "^http://services.org/path%?" )
matches( r.request.url, "[?&]offset=0&?" )
matches( r.request.url, "[?&]format=json&?" )
matches( r.request.url, "[?&]limit=50&?" )
matches( r.request.url, "[?&]key=356a192c7813b04c54574d18c28d46e6395428ab&?" )
matches( r.request.url, "[?&]signature=a358aa918f36156b215531e287f6d836415be582&?" )

