path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

# Patch the source properties onto the destination.
extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination

defaultConfig = {no_unnecessary_fat_arrows: {level: 'ignore'}}
configError = extend {}, defaultConfig, {no_class_fat_arrows: {level: 'error'}}

vows.describe('no_class_fat_arrows').addBatch({

    'eol':
        'should not warn by default': ->
            assert.isEmpty(coffeelint.lint("""
            class Foo
              foo: =>
            """, defaultConfig))

        'should warn when enabled': ->
            result = coffeelint.lint("""
            class Foo
              foo: =>
            """, configError)
            assert.equal(result.length, 1)
            assert.equal(result[0].rule,  'no_class_fat_arrows')
            assert.equal(result[0].level, 'error')

        'should work with nested classes': ->
            result = coffeelint.lint("""
            class Bar
              foo: ->
                class
                  bar2: =>
            """, configError)
            assert.equal(result.length, 1)
            assert.equal(result[0].rule,  'no_class_fat_arrows')
            assert.equal(result[0].level, 'error')

            # Same method name as external method.
            result = coffeelint.lint("""
            class Bar
              foo: ->
                class
                  foo: =>
            """, configError)
            assert.equal(result.length, 1)
            assert.equal(result[0].rule,  'no_class_fat_arrows')
            assert.equal(result[0].level, 'error')

        'should not warn without fat arrow': ->
            assert.isEmpty(coffeelint.lint("""
            class Foo
              foo: ->
            """, configError))

        'should not warn about private functions': ->
            assert.isEmpty(coffeelint.lint("""
            class Foo
              foo = =>
            """, configError))

}).export(module)
