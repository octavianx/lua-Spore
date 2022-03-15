#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'openssl') then
    skip_all 'no openssl'
end

plan(23)

local response = { status = 200, headers = {} }
require 'Spore.Protocols'.request = function (req)
    equals( req.url, "http://services.org:9999/dir/index.html", 'req.url' )
    return response
end -- mock

if not require_ok 'Spore.Middleware.Auth.Digest' then
    skip_rest "no Spore.Middleware.Auth.Digest"
    os.exit()
end
local mw = require 'Spore.Middleware.Auth.Digest'

local req = require 'Spore.Request'.new({ spore = { params = {} } })
is_table( req, "Spore.Request.new" )
is_table( req.headers )

local r = mw.call({}, req)
equals( r, nil )

local data = {
    username = 'Mufasa',
    password = 'Circle Of Life',
}
r = mw.call(data, req)
equals( r, nil )

req.env.spore.authentication = true
local cb = mw.call(data, req)
is_function( cb )
equals( req.headers['authorization'], nil )

local old_generate_nonce = mw.generate_nonce
mw.generate_nonce = function () return '0a4f113b' end  -- mock

req.method = 'GET'
req.url = 'http://services.org:9999/dir/index.html'
r = cb{
    status = 401,
    headers = {
        ['www-authenticate'] = [[Digest
                 realm="testrealm@host.com",
                 qop="auth,auth-int",
                 nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
                 opaque="5ccc069c403ebaf9f0171e9517f40e41"
]]
    },
}

equals( data.algorithm, 'MD5' )
equals( data.nc, 1 )
equals( data.realm, 'testrealm@host.com' )
equals( data.qop, 'auth' )
equals( data.nonce, 'dcd98b7102dd2f0e8b11d0f600bfb0c093' )
equals( data.opaque, '5ccc069c403ebaf9f0171e9517f40e41' )
equals( r, response )
equals( req.headers['authorization'], [[Digest username="Mufasa", realm="testrealm@host.com", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093", uri="/dir/index.html", algorithm="MD5", nc=00000001, cnonce="0a4f113b", response="6629fae49393a05397450978507c4ef1", opaque="5ccc069c403ebaf9f0171e9517f40e41", qop=auth]] )

cb = mw.call(data, req)
is_function( cb )
equals( req.headers['authorization'], [[Digest username="Mufasa", realm="testrealm@host.com", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093", uri="/dir/index.html", algorithm="MD5", nc=00000002, cnonce="0a4f113b", response="15b6bb427e3fecd23a43cb702ce447d5", opaque="5ccc069c403ebaf9f0171e9517f40e41", qop=auth]] )
r = cb(response)
equals( r, response )


mw.generate_nonce = old_generate_nonce
data = {
    username = 'Mufasa',
    password = 'Circle Of Life',
}
cb = mw.call(data, req)
local _ = cb{
    status = 401,
    headers = {
        ['www-authenticate'] = [[Digest
                 algorithm="MD5",
                 realm="testrealm@host.com",
                 nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
                 opaque="5ccc069c403ebaf9f0171e9517f40e41"
]]
    },
}
matches( req.headers['authorization'], [[opaque="5ccc069c403ebaf9f0171e9517f40e41"$]], 'no qop' )


error_matches( function ()
    local data = {
        username = 'Mufasa',
        password = 'Circle Of Life',
    }
    local cb = mw.call(data, req)
    local _ = cb{
        status = 401,
        headers = {
            ['www-authenticate'] = [[Digest qop="auth-int", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"]]
        },
   }
end, "auth%-int is not supported" )

error_matches( function ()
    local data = {
        username = 'Mufasa',
        password = 'Circle Of Life',
    }
    local cb = mw.call(data, req)
    local _ = cb{
        status = 401,
        headers = {
            ['www-authenticate'] = [[Digest algorithm="MD5-sess", qop="auth", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"]]
        },
   }
end, "MD5%-sess is not supported" )
