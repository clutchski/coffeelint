path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('comment_config').addBatch({

    'Disable statements':
        topic: () ->
            '''
            # coffeelint: disable=no_trailing_semicolons
            a 'you get a semi-colon';
            b 'you get a semi-colon';
            # coffeelint: enable=no_trailing_semicolons
            c 'everybody gets a semi-colon';
            '''

        'can disable rules in your config': (source) ->
            config =
                no_trailing_semicolons: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            assert.equal(errors[0].rule, 'no_trailing_semicolons')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 5)
            assert.ok(errors[0].message)

    'Disable all statements':
        topic: () ->
            '''
            # coffeelint: disable
            a 'you get a semi-colon';
            b 'you get a semi-colon';
            # coffeelint: enable
            c 'everybody gets a semi-colon';
            '''

        'can disable rules in your config': (source) ->
            config =
                no_trailing_semicolons: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            assert.equal(errors[0].rule, 'no_trailing_semicolons')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 5)
            assert.ok(errors[0].message)

    'Disable statements per line':
        topic: () ->
            '''
            a 'foo';  # coffeelint: disable-line=no_trailing_semicolons
            b 'bar';
            '''

        'can disable rules in your config': (source) ->
            config =
                no_trailing_semicolons: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            assert.equal(errors[0].rule, 'no_trailing_semicolons')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 2)
            assert.ok(errors[0].message)

    'Expand shortcuts':
        topic: () ->
            '''
            a 'foo';  # noqa
            b 'bar';
            '''

        'will expand and honor directive shortcuts': (source) ->
            config =
                no_trailing_semicolons: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            assert.equal(errors[0].rule, 'no_trailing_semicolons')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 2)
            assert.ok(errors[0].message)

    'Disable all statements per line':
        topic: () ->
            '''
            a 'foo';  # coffeelint: disable-line
            b 'bar';
            '''

        'can disable rules in your config': (source) ->
            config =
                no_trailing_semicolons: level: 'error'
                no_implicit_parens: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)
            assert.equal(errors[0].rule, 'no_implicit_parens')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 2)
            assert.ok(errors[0].message)
            assert.equal(errors[1].rule, 'no_trailing_semicolons')
            assert.equal(errors[1].level, 'error')
            assert.equal(errors[1].lineNumber, 2)
            assert.ok(errors[1].message)

    'Enable statements':
        topic: () ->
            '''
            # coffeelint: enable=no_implicit_parens
            a 'implicit parens here'
            b 'implicit parens', 'also here'
            # coffeelint: disable=no_implicit_parens
            c 'implicit parens allowed here'
            '''

        'can enable rules not in your config': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 2)

            assert.equal(errors[0].rule, 'no_implicit_parens')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 2)
            assert.ok(errors[0].message)

            assert.equal(errors[1].rule, 'no_implicit_parens')
            assert.equal(errors[1].level, 'error')
            assert.equal(errors[1].lineNumber, 3)
            assert.ok(errors[1].message)

    'Enable statements per line':
        topic: () ->
            '''
            a 'foo'
            b 'bar'  # coffeelint: enable-line=no_implicit_parens
            c 'baz'
            '''

        'can enable rules not in your config': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            assert.equal(errors[0].rule, 'no_implicit_parens')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 2)
            assert.ok(errors[0].message)

    'Revert to post-config state':
        topic: () ->
            '''
            # coffeelint: disable=no_trailing_semicolons,no_implicit_parens
            a 'you get a semi-colon';
            b 'you get a semi-colon';
            # coffeelint: enable
            c 'everybody gets a semi-colon';
            '''

        'will re-enable all rules in your config': (source) ->
            config =
                no_implicit_parens: level: 'error'
                no_trailing_semicolons: level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)

            assert.equal(errors[0].rule, 'no_implicit_parens')
            assert.equal(errors[0].level, 'error')
            assert.equal(errors[0].lineNumber, 5)
            assert.ok(errors[0].message)

            assert.equal(errors[1].rule, 'no_trailing_semicolons')
            assert.equal(errors[1].level, 'error')
            assert.equal(errors[1].lineNumber, 5)
            assert.ok(errors[1].message)

}).export(module)
