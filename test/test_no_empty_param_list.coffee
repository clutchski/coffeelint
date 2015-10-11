path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_empty_param_list'

vows.describe(RULE).addBatch({

    'Empty param list':
        topic:
            '''
            blah = () ->
            '''

        'are allowed by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden': (source) ->
            config = no_empty_param_list: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Empty parameter list is forbidden')
            assert.equal(error.rule, RULE)

}).export(module)
