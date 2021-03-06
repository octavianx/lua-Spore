#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'lxp.lom') then
    skip_all 'no xml'
end

plan(24)

if not require_ok 'Spore.Middleware.Format.XML' then
    skip_rest "no Spore.Middleware.Format.XML"
    os.exit()
end
local xml = require 'Spore.XML'
local options = { indent = '  ' }


equals( xml.dump({ root = 42 }, options), [[
<root>42</root>
]] )

equals( xml.dump({ root = 'text & <escape>' }, options), [[
<root>text &amp; &lt;escape&gt;</root>
]] )

equals( xml.dump({ root = { attr = 42 } }, options), [[
<root attr="42"></root>
]] )

equals( xml.dump({ root = { attr = 42, 'va', 'lue' } }, options), [[
<root attr="42">value</root>
]] )

equals( xml.dump({ root = { elt = { 'text' } } }, options), [[
<root>
  <elt>text</elt>
</root>
]] )

equals( xml.dump({ root = { attr1 = 1, elt = { attr2 = 2, 'text' } } }, options), [[
<root attr1="1">
  <elt attr2="2">text</elt>
</root>
]] )

equals( xml.dump({ root = { elt = { 'A', 'b', 'C' } } }, options), [[
<root>
  <elt>A</elt>
  <elt>b</elt>
  <elt>C</elt>
</root>
]] )

equals( xml.dump({ root = { attr1 = 1, elt = { 'A', 'b', 'C' } } }, options), [[
<root attr1="1">
  <elt>A</elt>
  <elt>b</elt>
  <elt>C</elt>
</root>
]] )

equals( xml.dump({ root = { outer = { inner = { 'text' } } } }, options), [[
<root>
  <outer>
    <inner>text</inner>
  </outer>
</root>
]] )

equals( xml.dump({ root = { attr1= 1, outer = { attr2 = 2, inner = { attr3 = 3, 'text' } } } }, options), [[
<root attr1="1">
  <outer attr2="2">
    <inner attr3="3">text</inner>
  </outer>
</root>
]] )

equals( xml.dump({ root = { outer = { inner = { 'A', 'b', 'C' } } } }, options), [[
<root>
  <outer>
    <inner>A</inner>
    <inner>b</inner>
    <inner>C</inner>
  </outer>
</root>
]] )

equals( xml.dump({ root = { attr1= 1, outer = { attr2 = 2, inner = { 'A', 'b', 'C' } } } }, options), [[
<root attr1="1">
  <outer attr2="2">
    <inner>A</inner>
    <inner>b</inner>
    <inner>C</inner>
  </outer>
</root>
]] )

equals( xml.dump({ root = { attr1= 1, outer = { attr2 = 2, inner = { attr3 = 3, 'A', 'b', 'C' } } } }, options), [[
<root attr1="1">
  <outer attr2="2">
    <inner attr3="3">AbC</inner>
  </outer>
</root>
]] )


options = { indent = '  ', key_attr = { elt = 'id' } }

local res = xml.dump({
    root = {
        attr1= 1,
        elt = {
            name1 = { 'A' },
            name2 = { 'b' },
            name3 = { 'C' },
        },
    }
}, options)
matches( res, [[^<root attr1="1">
  <elt ]] )
contains( res, [[
  <elt id="name1">A</elt>
]] )
contains( res, [[
  <elt id="name3">C</elt>
]] )
contains( res, [[
  <elt id="name2">b</elt>
]] )
matches( res, "</elt>\n</root>\n$" )

res = xml.dump({
    root = {
        attr1= 1,
        elt = {
            name1 = {
                inner = { attr = 'A', 'text' },
            },
            name2 = {
                inner = { attr = 'b', 'text' },
            },
            name3 = {
                inner = { attr = 'C', 'text' },
            },
        },
    }
}, options)
matches( res, [[^<root attr1="1">
  <elt ]] )
contains( res, [[
  <elt id="name1">
    <inner attr="A">text</inner>
  </elt>
]] )
contains( res, [[
  <elt id="name2">
    <inner attr="b">text</inner>
  </elt>
]] )
contains( res, [[
  <elt id="name3">
    <inner attr="C">text</inner>
  </elt>
]] )
matches( res, "</elt>\n</root>\n$" )
