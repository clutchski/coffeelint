path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('no_debugger').addBatch({

    'console calls':
        topic: '''
        console.log("hello world")
        '''

        'causes a warning when present': (source) ->
            errors = coffeelint.lint(source, {
                no_debugger:
                    'level': 'error'
                    "console": true
            })
            assert.isArray(errors)
            assert.lengthOf(errors, 1)

    'The debugger statement':
        topic: ->
            '''
            debugger
            '''

        'causes a warning when present': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.level, 'warn')
            assert.equal(error.lineNumber, 1)
            assert.equal(error.rule, 'no_debugger')

        'can be set to error': (source) ->
            errors = coffeelint.lint(source, {no_debugger: {'level': 'error'}})
            assert.isArray(errors)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.rule, 'no_debugger')

}).export(module)
