#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'openssl') then
    skip_all 'no openssl'
end

plan(14)

local response = { status = 200, headers = {} }
require 'Spore.Protocols'.request = function (req)
    response.request = req
    return response
end -- mock
require 'Spore.Request'.finalize = function (self)
    self.method = 'GET'
    self.env.QUERY_STRING = 'dummy'
    self.url = 'http://' .. self.env.SERVER_NAME .. ':9999/restapi/show?' .. self.env.QUERY_STRING
end -- mock

if not require_ok 'Spore.Middleware.Auth.AWS' then
    skip_rest "no Spore.Middleware.Auth.AWS"
    os.exit()
end
local mw = require 'Spore.Middleware.Auth.AWS'

local req = require 'Spore.Request'.new({
    SERVER_NAME = 'services.org',
    spore = {
        headers = {
            ['Date'] = 'AWS',
            ['Content-MD5'] = 'AWS',
        },
        params = {
            bucket = 'mybucket',
            ['x-amz-p1'] = 'foo',
            ['x-amz-P2'] = 'bar',
        },
        payload = 'PAYLOAD',
    }
})
is_table( req, "Spore.Request.new" )
is_table( req.headers )

local r = mw.call({}, req)
equals( r, nil )

local data = {
    aws_access_key  = 'xxx',
    aws_secret_key  = 'yyy',
}
r = mw.call(data, req)
equals( r, nil )

req.env.spore.authentication = true
r = mw.call(data, req)
equals( r, response )
equals( response.request.url, "http://mybucket.services.org:9999/restapi/show?dummy", "url" )
matches( response.request.headers['authorization'], "^AWS xxx:", "authorization" )
matches( response.request.headers['date'], "GMT$", "date" )
equals( response.request.headers['x-amz-p1'], 'foo', "x-amz-p1" )
equals( response.request.headers['x-amz-p2'], 'bar', "x-amz-p2" )
equals( response.request.headers['content-length'], 7, "content-length" )
equals( response.request.headers['content-type'], 'application/x-www-form-urlencoded', "content-type" )
equals( response.request.headers['content-md5'], 'ca8fef80e43c8db749b7c9406d535b1a', "content-md5" )

