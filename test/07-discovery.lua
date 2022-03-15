#!/usr/bin/env lua

require 'Test.Assertion'

plan(12)

local doc = [[
{
  "title": "api",
  "version": "v1",
  "description": "api for unit test",
  "basePath": "/restapi/",
  "documentationLink": "http://developers.google.com/discovery",
  "resources": {
    "test": {
      "methods": {
        "get": {
          "id": "foo.get_info",
          "path": "/show",
          "httpMethod": "GET",
          "parameters": {
            "user": {},
            "border": {}
          }
        }
      }
    }
  }
}
]]
require 'Spore.Protocols'.slurp = function ()
    return doc
end -- mock

require 'Spore'.new_from_lua = function (t)
    return t
end --mock

local m = require 'Spore.GoogleDiscovery'
is_table( m, "Spore.GoogleDiscovery" )
equals( m, package.loaded['Spore.GoogleDiscovery'] )

is_function( m.new_from_discovery )
is_function( m.convert )

local spec = m.new_from_discovery('mock')
equals( spec.name, 'api' )
equals( spec.version, 'v1' )
equals( spec.description, 'api for unit test' )
equals( spec.base_url, 'https://www.googleapis.com/restapi/' )
equals( spec.meta.documentation, 'http://developers.google.com/discovery' )
local meth = spec.methods.get_info
is_table( meth )
equals( meth.path, '/show' )
equals( meth.method, 'GET' )
