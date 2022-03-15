codes = true
read_globals = {
    -- Test.More
    'plan',
    'done_testing',
    'skip_all',
    'BAIL_OUT',
    'subtest',
    'diag',
    'note',
    'skip',
    'todo_skip',
    'skip_rest',
    'todo',
    -- Test.Assertion
    'equals',
    'is_function',
    'is_nil',
    'is_string',
    'is_table',
    'falsy',
    'truthy',
    'contains',
    'matches',
    'error_matches',
    'not_errors',
    'require_ok',
}
globals = {
    -- Spore
    'Spore',
}
ignore = { '212/req', '212/self' }
files['test/22-oauth.lua'].ignore = { '631' }
files['test/25-auth_digest.lua'].ignore = { '431', '631' }
files['test/33-format_xml.lua'].ignore = { '631' }
files['test/41-proxy_basic.lua'].ignore = { '122/os' }
