path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('parens').addBatch({

    'Implicit parens' :

        topic : () ->
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

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {no_implicit_parens : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Implicit parens are forbidden')
            assert.equal(error.rule, 'no_implicit_parens')

    'No implicit parens strict' :
        topic: """
            blah = (a, b) ->
            blah 'a'
            , 'b'
        """

        "blocks all implicit parens by default": (source) ->
            config = {no_implicit_parens : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            assert.equal(rule, 'no_implicit_parens') for {rule} in errors

        "allows parens at the end of lines when strict is false": (source) ->
            config =
                no_implicit_parens:
                    level:'error'
                    strict: false
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Nested no implicit parens strict' :
        topic: """
            blah = (a, b) ->

            blah 'a'
            , blah('c', 'd')

            blah 'a'
            , (blah 'c'
            , 'd')
        """

        "blocks all implicit parens by default": (source) ->
            config = {no_implicit_parens : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 3)
            assert.equal(rule, 'no_implicit_parens') for {rule} in errors

        "allows parens at the end of lines when strict is false": (source) ->
            config =
                no_implicit_parens:
                    level:'error'
                    strict: false
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

}).export(module)
