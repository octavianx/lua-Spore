#!/usr/bin/env lua

require 'Test.Assertion'

plan(13)

if not require_ok 'Spore.Middleware.Format.JSON' then
    skip_rest "no Spore.Middleware.Format.JSON"
    os.exit()
end
local mw = require 'Spore.Middleware.Format.JSON'

local env = {
    spore = {
        payload = {
            lua = 'table',
        },
    },
}
local req = require 'Spore.Request'.new(env)
local cb = mw.call({}, req)
is_function( cb, "returns a function" )
equals( env.spore.payload, [[{"lua":"table"}]], "payload encoded")

local resp = {
    status = 200,
    headers = {},
    body = [[
{
    "username" : "john",
    "password" : "s3kr3t"
}
]]
}

local ret = cb(resp)
equals( req.headers['accept'], 'application/json' )
equals( ret, resp, "returns same table" )
equals( ret.status, 200, "200 OK" )
local data = ret.body
is_table( data )
equals( data.username, 'john', "username is john" )
equals( data.password, 's3kr3t', "password is s3kr3t" )

resp.body = [[
{
    "username" : "john",
    INVALID
}
]]
env.spore.errors = io.tmpfile()
local r, ex = pcall(cb, resp)
falsy( r )
matches( ex.reason, "unexpected character", "Invalid JSON data" )
env.spore.errors:seek'set'
local msg = env.spore.errors:read '*l'
matches( msg, "unexpected character", "Invalid JSON data" )
local _ = env.spore.errors:read '*l'

msg = env.spore.errors:read '*a'
equals( msg, resp.body .. "\n")
