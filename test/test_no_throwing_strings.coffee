path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_throwing_strings'

vows.describe(RULE).addBatch({

    'Throwing strings':
        topic:
            '''
            throw 'my error'
            throw "#{1234}"
            throw """
                long string
            """
            '''

        'is forbidden by default': (source) ->
            errors = coffeelint.lint(source)
            assert.lengthOf(errors, 3)
            error = errors[0]
            assert.equal(error.message, 'Throwing strings is forbidden')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config = {no_throwing_strings: {level: 'ignore'}}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

}).export(module)
