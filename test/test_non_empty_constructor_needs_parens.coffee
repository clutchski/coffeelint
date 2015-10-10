path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('non_empty_constructor_needs_parens').addBatch({


    'Missing Parentheses on "new Foo 1, 2"':
        topic:
            '''
            class Foo

            a = new Foo
            b = new Foo()
            # Warn about missing parens here
            c = new Foo 1, 2
            d = new Foo
              config: 'parameter'
            e = new bar.foo.Foo 1, 2
            f = new bar.foo.Foo
              config: 'parameter'
            # But not here
            g = new Foo(1, 2)
            h = new Foo(
              config: 'parameter'
            )
            i = new bar.foo.Foo(1, 2)
            j = new bar.foo.Foo(
              config: 'parameter'
            )
            '''

        'warns about missing parens': (source) ->
            config =
                non_empty_constructor_needs_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 4)
            assert.equal(errors[0].lineNumber, 6)
            assert.equal(errors[0].rule, 'non_empty_constructor_needs_parens')
            assert.equal(errors[1].lineNumber, 7)
            assert.equal(errors[1].rule, 'non_empty_constructor_needs_parens')
            assert.equal(errors[2].lineNumber, 9)
            assert.equal(errors[2].rule, 'non_empty_constructor_needs_parens')
            assert.equal(errors[3].lineNumber, 10)
            assert.equal(errors[3].rule, 'non_empty_constructor_needs_parens')

}).export(module)
