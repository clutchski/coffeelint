path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

config =
    no_unnecessary_fat_arrows: { level: 'ignore' }
    no_private_function_fat_arrows: { level: 'error' }

RULE = 'no_private_function_fat_arrows'

vows.describe(RULE).addBatch({
    'eol':
        'should warn with fat arrow': ->
            result = coffeelint.lint('''
            class Foo
              foo = =>
            ''', config)
            assert.equal(result.length, 1)
            assert.equal(result[0].rule, RULE)
            assert.equal(result[0].level, 'error')

        'should work with nested classes': ->
            result = coffeelint.lint('''
            class Bar
              foo = ->
                class
                  bar2 = =>
            ''', config)
            assert.equal(result.length, 1)
            assert.equal(result[0].rule, RULE)
            assert.equal(result[0].level, 'error')

            # Same method name as external function.
            result = coffeelint.lint('''
            class Bar
              foo = ->
                class
                  foo = =>
            ''', config)
            assert.equal(result.length, 1)
            assert.equal(result[0].rule, RULE)
            assert.equal(result[0].level, 'error')

        'should not warn without fat arrow': ->
            assert.isEmpty(coffeelint.lint('''
            class Foo
              foo = ->
            ''', config))

}).export(module)
