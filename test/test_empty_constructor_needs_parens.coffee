path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'empty_constructor_needs_parens'

vows.describe(RULE).addBatch({

    'Make sure no errors if constructors are indexed (#421)':
        topic:
            '''
            new OPERATIONS[operationSpec.type] operationSpec.field

            new Foo[bar].baz[qux] param1
            '''

        'should pass': (source) ->
            config =
                empty_constructor_needs_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'Missing Parentheses on "new Foo"':
        topic:
            '''
            class Foo

            # Warn about missing parens here
            a = new Foo
            b = new bar.foo.Foo
            # The parens make it clear no parameters are intended
            c = new Foo()
            d = new bar.foo.Foo()
            e = new Foo 1, 2
            f = new bar.foo.Foo 1, 2
            # Since this does have a parameter it should not require parens
            g = new bar.foo.Foo
              config: 'parameter'
            '''

        'warns about missing parens': (source) ->
            config =
                empty_constructor_needs_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)
            assert.equal(errors[0].lineNumber, 4)
            assert.equal(errors[0].rule, RULE)
            assert.equal(errors[1].lineNumber, 5)
            assert.equal(errors[1].rule, RULE)

}).export(module)
