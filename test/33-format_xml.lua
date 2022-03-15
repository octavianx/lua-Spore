#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'lxp.lom') then
    skip_all 'no xml'
end

plan(27)

if not require_ok 'Spore.Middleware.Format.XML' then
    skip_rest "no Spore.Middleware.Format.XML"
    os.exit()
end
local mw = require 'Spore.Middleware.Format.XML'

local payload = {
    config = {
        logdir = '/var/log/foo/',
        debugfile = '/tmp/foo.debug',
        server = {
            sahara = {
                address = {
                    '10.0.0.101',
                    '10.0.1.101',
                },
            },
            gobi = {
                address = {
                    '10.0.0.102',
                },
            },
            kalahari = {
                address = {
                    '10.0.0.103',
                    '10.0.1.103',
                },
            },
        },
    },
}
local env = {
    spore = {
        payload = payload
    },
}
local req = require 'Spore.Request'.new(env)
local cb = mw.call({}, req)
is_function( cb, "returns a function" )

matches( env.spore.payload, "^<config ", "payload encoded" )
contains( env.spore.payload, [[ logdir="/var/log/foo/"]] )
contains( env.spore.payload, [[ debugfile="/tmp/foo.debug"]] )
contains( env.spore.payload, [[><server><]] )
contains( env.spore.payload, [[><sahara><address>10.0.0.101</address><address>10.0.1.101</address></sahara><]] )
contains( env.spore.payload, [[><gobi><address>10.0.0.102</address></gobi><]] )
contains( env.spore.payload, [[><kalahari><address>10.0.0.103</address><address>10.0.1.103</address></kalahari><]] )
matches( env.spore.payload, "</server></config>$" )


env.spore.payload = payload
req = require 'Spore.Request'.new(env)
cb = mw.call({ indent = '  ', key_attr = { server = 'name' } }, req)
matches( env.spore.payload, "^<config ", "payload encoded with options" )
contains( env.spore.payload, [[ logdir="/var/log/foo/"]] )
contains( env.spore.payload, [[ debugfile="/tmp/foo.debug"]] )
contains( env.spore.payload, [[
  <server name="sahara">
    <address>10.0.0.101</address>
    <address>10.0.1.101</address>
  </server>
]] )
contains( env.spore.payload, [[
  <server name="gobi">
    <address>10.0.0.102</address>
  </server>
]] )
contains( env.spore.payload, [[
  <server name="kalahari">
    <address>10.0.0.103</address>
    <address>10.0.1.103</address>
  </server>
]] )
matches( env.spore.payload, "\n</config>\n$" )

local resp = {
    status = 200,
    headers = {},
    body = [[
<user username="john" password="s3kr3t" />
]]
}

local ret = cb(resp)
equals( req.headers['accept'], 'text/xml' )
equals( ret, resp, "returns same table" )
equals( ret.status, 200, "200 OK" )
local data = ret.body
is_table( data )
equals( data.user.username, 'john', "username is john" )
equals( data.user.password, 's3kr3t', "password is s3kr3t" )

resp.body = [[
{ INVALID }
]]
env.spore.errors = io.tmpfile()
local r, ex = pcall(cb, resp)
falsy( r )
equals( ex.reason, "not well-formed (invalid token)" )
env.spore.errors:seek'set'
local msg = env.spore.errors:read '*l'
equals( msg, "not well-formed (invalid token)", "Invalid XML" )

msg = env.spore.errors:read '*a'
equals( msg, resp.body .. "\n")
