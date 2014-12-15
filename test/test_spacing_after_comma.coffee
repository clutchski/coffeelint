path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('commas').addBatch({

    'Whitespace after commas' :

        topic : () ->
            "doSomething(foo = ',',bar)\nfooBar()"

        'permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 0)

        'permitted by default' : (source) ->
            config = {spacing_after_comma : {level:'warn'}}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, "Spaces are required after commas")
            assert.equal(error.rule, 'spacing_after_comma')

    'newline after commas' :

        topic: () ->
            '''
            multiLineFuncCall(
              arg1,
              arg2,
              arg3
            )
            '''

        'should not issue warns' : (source) ->
            config = {spacing_after_comma : {level:'warn'}}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

}).export(module)
