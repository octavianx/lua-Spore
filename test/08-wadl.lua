#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'lxp.lom') then
    skip_all 'no xml'
end

plan(12)

local doc = [[
<?xml version="1.0"?>
<application>
  <resources base="http://services.org:9999/restapi/">
    <resource path="show">
      <method name="GET" id="get_info">
        <request>
          <param name="user" type="xsd:string" style="query" required="true"/>
          <param name="border" type="xsd:string" style="query" required="false"/>
        </request>
        <response status="200" />
      </method>
    </resource>
  </resources>
</application>
]]
require 'Spore.Protocols'.slurp = function ()
    return doc
end -- mock

require 'Spore'.new_from_lua = function (t)
    return t
end --mock

local m = require 'Spore.WADL'
is_table( m, "Spore.WADL" )
equals( m, package.loaded['Spore.WADL'] )

is_function( m.new_from_wadl )
is_function( m.convert )

local spec = m.new_from_wadl('mock')
local meth = spec.methods.get_info
is_table( meth )
equals( meth.base_url, 'http://services.org:9999/restapi/' )
equals( meth.path, 'show' )
equals( meth.method, 'GET' )
equals( #meth.required_params, 1 )
equals( meth.required_params[1], 'user' )
equals( #meth.optional_params, 1 )
equals( meth.optional_params[1], 'border' )
