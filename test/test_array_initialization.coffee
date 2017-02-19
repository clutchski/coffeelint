path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('array_initialization').addBatch({

    'Array initialization using the Array constructor' :

        topic : () ->
            '''
            a = []
            a = new Array
            '''

        'is allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {array_initialization : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 2)
            assert.equal(
                error.message,
                'Array initialization using the Array constructor is forbidden'
            )
            assert.equal(error.rule, 'array_initialization')

}).export(module)
