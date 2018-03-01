path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('missing_parseint_radix').addBatch({

    'parseInt without radix':
        topic : "parseInt '08'"

        'should warn by default' : (source) ->
            errors = coffeelint.lint(source)
            {lineNumber, message, rule, level} = errors[0]

            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            assert.equal(lineNumber, 1)
            assert.equal(message, 'parseInt is missing the radix argument')
            assert.equal(rule, 'missing_parseint_radix')
            assert.equal(level, 'warn')

        'can be forbidden' : (source) ->
            config = {missing_parseint_radix : {level:'error'}}
            errors = coffeelint.lint(source, config)
            {lineNumber, message, rule, level} = errors[0]

            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            assert.equal(lineNumber, 1)
            assert.equal(message, 'parseInt is missing the radix argument')
            assert.equal(rule, 'missing_parseint_radix')
            assert.equal(level, 'error')

        'can be permitted' : (source) ->
            config = {missing_parseint_radix : {level:'ignore'}}
            errors = coffeelint.lint(source, config)

            assert.isArray(errors)
            assert.isEmpty(errors)

    'parseInt with radix':
        topic : "parseInt '08', 10"

        'should not cause a warning' : (source) ->
            errors = coffeelint.lint(source)

            assert.isArray(errors)
            assert.isEmpty(errors)

        'should not cause an error' : (source) ->
            config = {missing_parseint_radix : {level:'error'}}
            errors = coffeelint.lint(source, config)

            assert.isArray(errors)
            assert.isEmpty(errors)

}).export(module)

