path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_interpolation_in_single_quotes'

vows.describe(RULE).addBatch({

    'Interpolation in single quotes':
        topic:
            '''
            foo = '#{inter}foo#{polation}'
            '''

        'interpolation in single quotes is allowed by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'interpolation in single quotes can be forbidden': (source) ->
            config = no_interpolation_in_single_quotes: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.rule, RULE)

    'Interpolation in double quotes':
        topic:
            '''
            foo = "#{inter}foo#{polation}"
            bar = "ive\#{escaped}"
            '''

        'interpolation in double quotes is always allowed': (source) ->
            config = no_interpolation_in_single_quotes: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

}).export(module)
