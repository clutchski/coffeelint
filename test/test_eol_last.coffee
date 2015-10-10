path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

configError = {eol_last: {level: 'error'}}

RULE = 'eol_last'

vows.describe(RULE).addBatch({

    'eol':
        'should not warn by default': ->
            assert.isEmpty(coffeelint.lint('foobar'))

        'should warn when enabled': ->
            result = coffeelint.lint('foobar', configError)
            assert.equal(result.length, 1)
            assert.equal(result[0].level, 'error')
            assert.equal(result[0].rule, RULE)

        'should warn when enabled with multiple newlines': ->
            result = coffeelint.lint('foobar\n\n', configError)
            assert.equal(result.length, 1)
            assert.equal(result[0].level, 'error')
            assert.equal(result[0].rule, RULE)

        'should not warn with newline': ->
            assert.isEmpty(coffeelint.lint('foobar\n', configError))

}).export(module)
