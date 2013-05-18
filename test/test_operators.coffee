path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('operators').addBatch({

    'Coffeescript and or is isnt' :

        topic : () ->
            '''
            foo == bar
            foo != bar
            foo && bar
            foo || bar
            '''

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can forbid is and isnt' : (source) ->
            config =
                idomatic_is_isnt: {level: 'error'}

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            msg = 'Ensure that idomatic operators are used for == and !=.'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'idomatic_is_isnt')

        'can forbid and or' : (source) ->
            config =
                idomatic_and_or: {level: 'error'}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 3)
            msg = 'Ensure that idomatic operators are used for && and ||.'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'idomatic_and_or')

}).export(module)
