path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_tabs'

vows.describe(RULE).addBatch({

    'Tabs':
        topic:
            '''
            x = () ->
            \ty = () ->
            \t\treturn 1234
            z = 1\t
            '''

        'can be forbidden': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 6)
            error = errors[1]
            assert.equal(error.lineNumber, 2)
            assert.equal(error.message, 'Line contains tab indentation')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config =
                no_tabs: { level: 'ignore' }
                indentation: { level: 'error', value: 1 }
                no_trailing_whitespace: { level: 'ignore' }

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'are forbidden by default': (source) ->
            config =
              indentation: { level: 'error', value: 1 }
              no_trailing_whitespace: { level: 'ignore' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.equal(errors.length, 3)
            assert.equal(rule, RULE) for { rule } in errors

        'are allowed in strings': () ->
            source = "x = () -> '\t'"
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 0)

    'Tabs in multi-line strings':
        topic:
            '''
            x = 1234
            y = """
            \t\tasdf
            """
            '''

        'are ignored': (errors) ->
            errors = coffeelint.lint(errors)
            assert.isEmpty(errors)

    'Tabs in Heredocs':
        topic:
            '''
            ###
            \t\tMy Heredoc
            ###
            '''

        'are ignored': (errors) ->
            errors = coffeelint.lint(errors)
            assert.isEmpty(errors)

    'Tabs in multi line regular expressions':
        topic:
            '''
            ///
            \t\tMy Heredoc
            ///
            '''

        'are ignored': (errors) ->
            errors = coffeelint.lint(errors)
            assert.isEmpty(errors)

}).export(module)
