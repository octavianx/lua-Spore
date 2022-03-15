#!/usr/bin/env lua

require 'Test.Assertion'

plan(9)

package.loaded['socket.http'] = {
    request = function (req) return req, 200 end -- mock
}

if not require_ok 'Spore.Middleware.Parameter.Default' then
    skip_rest "no Spore.Middleware.Parameter.Default"
    os.exit()
end

local Spore = require 'Spore'
local client = Spore.new_from_spec('./test/api.json', {})
client:enable('Parameter.Default', {
    user = 'John',
    border = 0,
    dummy = 1,
})

equals( Spore.early_validate, false, "early_validate" )

local r = client:get_info()
equals( r.request.env.spore.params.user, 'John' )
equals( r.request.env.spore.params.border, 0 )
equals( r.request.env.spore.params.dummy, nil )

r = client:get_info{ user = 'Joe', border = 1 }
equals( r.request.env.spore.params.user, 'Joe' )
equals( r.request.env.spore.params.border, 1 )

r = client:get_user_info{ payload = 'opaque data' }
equals( r.request.env.spore.params.user, 'John' )
equals( r.request.env.spore.params.border, 0 )

