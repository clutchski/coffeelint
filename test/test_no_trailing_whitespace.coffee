path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_trailing_whitespace'

vows.describe(RULE).addBatch({

    'Trailing whitespace':
        topic:
            '''
            x = 1234      \ny = 1
            '''

        'is forbidden by default': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line ends with trailing whitespace')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config = no_trailing_whitespace: { level: 'ignore' }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'Trailing whitespace in comments':
        topic:
            '''
            x = 1234  # markdown comment    \ny=1
            '''

        'is forbidden by default': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line ends with trailing whitespace')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config = no_trailing_whitespace: { allowed_in_comments: true }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'a # in a string':
        # writen this way to preserve spacing
        topic: '''x = "some # string"   '''

        'does not confuse trailing_whitespace': (source) ->
            config = no_trailing_whitespace: { allowed_in_comments: true }
            errors = coffeelint.lint(source, config)
            assert.isNotEmpty(errors)

    'Trailing whitespace in block comments':
        topic:
            '''
            ###\nblock comment with trailing space:   \n###
            '''

        'is forbidden by default': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.lineNumber, 2)
            assert.equal(error.message, 'Line ends with trailing whitespace')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config = no_trailing_whitespace: { allowed_in_comments: true }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'On empty lines': # https://github.com/clutchski/coffeelint/issues/39
        topic:
            '''
            x = 1234\n     \n
            '''

        'allowed by default': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 0)

        'can be forbidden': (source) ->
            config =
                no_trailing_whitespace:
                    allowed_in_empty_lines: false

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.lineNumber, 2)
            assert.equal(error.message, 'Line ends with trailing whitespace')
            assert.equal(error.rule, RULE)

    'Trailing tabs':
        topic:
            '''
            x = 1234\t
            '''

        'are forbidden as well': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)

    'Windows line endings':
        topic:
            '''
            x = 1234\r\ny = 5678
            '''

        'are permitted': (source) ->
            assert.isEmpty(coffeelint.lint(source))

}).export(module)
