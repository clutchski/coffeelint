path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_backticks'

vows.describe(RULE).addBatch({

    'Backticks':
        topic:
            '''
            `with(document) alert(height);`
            '''

        'are forbidden by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, RULE)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Backticks are forbidden')

        'can be permitted': (source) ->
            config = no_backticks: { level: 'ignore' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Ignore string interpolation from comments':
        topic:
            '''
            <div>{### comment ###}</div>
            '''
        'are ignored when no_backtick rule is enabled': (source) ->
            config = no_backticks: { level: 'error' }
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

}).export(module)
