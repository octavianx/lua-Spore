#!/usr/bin/env lua

local Request = require 'Spore.Request'

require 'Test.Assertion'

plan(46)

local env = {
    HTTP_USER_AGENT = 'MyAgent',
    PATH_INFO       = '/restapi',
    REQUEST_METHOD  = 'PET',
    SERVER_NAME     = 'services.org',
    SERVER_PORT     = 9999,
    spore = {
        url_scheme = 'prot',
        params = {
            prm1 = 1,
            prm2 = "value2",
            prm3 = "Value Z",
        },
        method = {},
    },
}
local req = Request.new(env)
is_table( req, "Spore.Request.new" )
equals( req.env, env )
equals( req.redirect, false )
is_table( req.headers )
equals( req.headers['user-agent'], 'MyAgent' )
is_function( req.finalize )
equals( req.url, nil )
equals( req.method, nil )

env.PATH_INFO = '/restapi/usr{prm1}/show/{prm2}'
env.QUERY_STRING = nil
req:finalize()
equals( req.method, 'PET', "method" )
equals( req.url, 'prot://services.org:9999/restapi/usr1/show/value2?prm3=Value%20Z', "url" )
equals( env.PATH_INFO, '/restapi/usr1/show/value2' )
equals( env.QUERY_STRING, 'prm3=Value%20Z' )
req.headers.auth = nil
req.url = nil

env.PATH_INFO = '/restapi/{prm3}/show'
env.QUERY_STRING = nil
env.REQUEST_METHOD = 'TEP'
req:finalize()
equals( req.method, 'TEP', "method" )
matches( req.url, '^prot://services.org:9999/restapi/Value%%20Z/show%?prm', "url" )
equals( env.PATH_INFO, '/restapi/Value%20Z/show' )
matches( env.QUERY_STRING, '&?prm1=1&?' )
matches( env.QUERY_STRING, '&?prm2=value2&?' )
req.headers.auth = nil
req.url = nil

env.PATH_INFO = '/restapi/usr{prm1}/show/{prm2}'
env.QUERY_STRING = nil
env.spore.params.prm3 = nil
req:finalize()
equals( req.url, 'prot://services.org:9999/restapi/usr1/show/value2', "url" )
equals( env.PATH_INFO, '/restapi/usr1/show/value2' )
equals( env.QUERY_STRING, nil )
req.url = nil

env.PATH_INFO = '/restapi/usr{prm1}/show/{prm2}'
env.QUERY_STRING = nil
env.spore.params.prm2 = 'path2/value2'
req:finalize()
equals( req.url, 'prot://services.org:9999/restapi/usr1/show/path2/value2', "url" )
equals( env.PATH_INFO, '/restapi/usr1/show/path2/value2' )
equals( env.QUERY_STRING, nil )
env.spore.params.prm2 = 'value2'
req.url = nil

env.PATH_INFO = '/restapi/doit'
env.QUERY_STRING = 'action=action1'
req:finalize()
matches( req.url, '^prot://services.org:9999/restapi/doit%?', "url" )
equals( env.PATH_INFO, '/restapi/doit' )
matches( env.QUERY_STRING, '&?action=action1&?' )
matches( env.QUERY_STRING, '&?prm1=1&?' )
matches( env.QUERY_STRING, '&?prm2=value2&?' )
req.url = nil

env.PATH_INFO = '/restapi/path'
env.QUERY_STRING = nil
env.spore.params.prm3 = "Value Z"
env.spore.form_data = {
    form1 = 'f({prm1})',
    form2 = 'g({prm2})',
    form3 = 'h({prm3})',
    form7 = 'r({prm7})',
}
req:finalize()
equals( req.url, 'prot://services.org:9999/restapi/path', "url" )
equals( env.PATH_INFO, '/restapi/path' )
equals( env.QUERY_STRING, nil )
equals( env.spore.form_data.form1, "f(1)", "form-data" )
equals( env.spore.form_data.form2, "g(value2)" )
equals( env.spore.form_data.form3, "h(Value Z)" )
equals( env.spore.form_data.form7, nil )
req.url = nil

env.QUERY_STRING = nil
env.spore.form_data = nil
env.spore.headers = {
    head1 = 'f({prm1})',
    Head2 = 'g({prm2}); {prm1}',
    HeaD3 = 'h({prm3})',
    HEAD7 = 'r({prm7})',
}
req:finalize()
equals( req.url, 'prot://services.org:9999/restapi/path', "url" )
equals( env.PATH_INFO, '/restapi/path' )
equals( env.QUERY_STRING, nil )
equals( env.spore.form_data, nil )
equals( req.headers.head1, "f(1)", "headers" )
equals( req.headers.head2, "g(value2); 1" )
equals( req.headers.head3, "h(Value Z)" )
equals( req.headers.head7, nil )
req.url = nil

env.QUERY_STRING = nil
env.spore.params.prm1 = 2
env.spore.params.prm2 = 'VALUE2'
req:finalize()
equals( req.headers.head1, "f(2)", "headers" )
equals( req.headers.head2, "g(VALUE2); 2" )
equals( req.headers.head3, "h(Value Z)" )
