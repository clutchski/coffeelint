path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_spaces'

tabsConfig =
    indentation: { level: 'error', value: 1 }
    no_tabs: { level: 'ignore' }
    no_spaces: { level: 'error' }

vows.describe(RULE).addBatch({

    'Spaces':
        topic:
            '''
            x = () ->
              y = () ->
                return 1234
            '''

        'can be forbidden': (source) ->
            errors = coffeelint.lint(source, tabsConfig)
            assert.equal(errors.length, 4)
            error = errors[1]
            assert.equal(error.lineNumber, 2)
            assert.equal(error.message, 'Line contains space indentation')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config =
                no_tabs: { level: 'ignore' }
                no_spaces: { level: 'ignore' }

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'are permitted by default': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 0)

        'are allowed in strings': () ->
            source = "x = () -> ' '"
            errors = coffeelint.lint(source, tabsConfig)
            assert.equal(errors.length, 0)

    'Spaces in chains':
        topic:
            '''
            startingChain()
                .hello()
            \t.world()
            \t.today((x) -> x + 2)
            '''

        'can be forbidden': (source) ->
            errors = coffeelint.lint(source, tabsConfig)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 2)
            assert.equal(error.message, 'Line contains space indentation')
            assert.equal(error.rule, RULE)

        'can be permitted': (source) ->
            config =
                no_tabs: { level: 'ignore' }
                no_spaces: { level: 'ignore' }
                indentation: { level: 'ignore' }

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'Spaces in multi-line strings':
        topic:
            '''
            x = 1234
            y = """
                asdf
            """
            '''

        'are ignored': (errors) ->
            errors = coffeelint.lint(errors, tabsConfig)
            assert.isEmpty(errors)

    'Spaces in Heredocs':
        topic:
            '''
            ###
                My Heredoc
            ###
            '''

        'are ignored': (errors) ->
            errors = coffeelint.lint(errors, tabsConfig)
            assert.isEmpty(errors)

    'Spaces in multi line regular expressions':
        topic:
            '''
            ///
                My Heredoc
            ///
            '''

        'are ignored': (errors) ->
            errors = coffeelint.lint(errors, tabsConfig)
            assert.isEmpty(errors)

}).export(module)
