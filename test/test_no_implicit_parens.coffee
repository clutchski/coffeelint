path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_implicit_parens'

vows.describe(RULE).addBatch({

    'Implicit parens':
        topic:
            '''
            console.log 'implict parens'
            blah = (a, b) ->
            blah 'a', 'b'

            class A
              @configure(1, 2, 3)

              constructor: ->

            class B
              _defaultC = 5

              constructor: (a) ->
                @c = a ? _defaultC
            '''

        'are allowed by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden': (source) ->
            config = no_implicit_parens: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Implicit parens are forbidden')
            assert.equal(error.rule, RULE)

    'No implicit parens strict':
        topic:
            '''
            blah = (a) ->
            blah
              foo: 'bar'

            blah = (a, b) ->
            blah 'a'
            , 'b'
            '''

        'blocks all implicit parens by default': (source) ->
            config = no_implicit_parens: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(rule, RULE) for { rule } in errors

        'allows parens at the end of lines when strict is false': (source) ->
            config =
                no_implicit_parens:
                    level: 'error'
                    strict: false
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Nested no implicit parens strict':
        topic:
            '''
            blah = (a) ->
            blah
              foo: blah('a')

            blah = (a, b) ->

            blah 'a'
            , blah('c', 'd')

            blah 'a'
            , (blah 'c'
            , 'd')
            '''

        'blocks all implicit parens by default': (source) ->
            config = no_implicit_parens: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 4)
            assert.equal(rule, RULE) for { rule } in errors

        'allows parens at the end of lines when strict is false': (source) ->
            config =
                no_implicit_parens:
                    level: 'error'
                    strict: false
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Test for when implicit parens are on the last line':
        topic:
            '''
            class Something
              constructor: ->
                return $ '#something'

              yo: ->

            class AnotherSomething
              constructor: ->
                return $ '#something'

            blah 'a'
            , blah('c', 'd')
            '''

        'throws three errors when strict is true': (source) ->
            config =
                no_implicit_parens:
                    level: 'error'
                    strict: true

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 3)
            assert.equal(errors[0].rule, RULE)
            assert.equal(errors[1].rule, RULE)
            assert.equal(errors[2].rule, RULE)

        # When implicit parens are separated out on multiple lines
        # and strict is set to false, do not return an error.
        'throws two errors when strict is false': (source) ->
            config =
                no_implicit_parens:
                    level: 'error'
                    strict: false

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(errors[0].rule, RULE)
            assert.equal(errors[1].rule, RULE)

}).export(module)
