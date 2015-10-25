path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_debugger'

vows.describe(RULE).addBatch({

    'console calls':
        topic:
            '''
            console.log("hello world")
            '''

        'causes a warning when present': (source) ->
            config = no_debugger: { level: 'error', console: true }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)

    'The debugger statement':
        topic:
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
            assert.equal(error.rule, RULE)

        'can be set to error': (source) ->
            config = no_debugger: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.rule, RULE)

}).export(module)
