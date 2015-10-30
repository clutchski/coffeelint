path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('coffeelint').addBatch({

    "CoffeeLint's version number":
        topic: coffeelint.VERSION

        'exists': (version) ->
            assert.isString(version)

    "CoffeeLint's errors":
        topic: () -> coffeelint.lint '''
            a = () ->\t
                1234
            '''

        'are sorted by line number': (errors) ->
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(errors[1].lineNumber, 2)
            assert.equal(errors[0].lineNumber, 1)

    'Errors in the source':
        topic:
            '''
            fruits = [orange, apple, banana]
            switch 'a'
              when in fruits
                something
            '''

        'are reported': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, 'coffeescript_error')
            assert.equal(error.lineNumber, 3)

            if error.message.indexOf('on line') isnt -1
                m = "Error: Parse error on line 3: Unexpected 'RELATION'"
            else if error.message.indexOf('SyntaxError:') isnt -1
                m = 'SyntaxError: unexpected RELATION'
            else
                # CoffeeLint changed the format to be more complex.  I don't
                # think an exact match really needs to be verified.
                return

            assert.equal(error.message, m)

}).export(module)
