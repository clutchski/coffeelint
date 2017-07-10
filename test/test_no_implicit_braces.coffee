path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_implicit_braces'

vows.describe(RULE).addBatch({

    'Implicit braces':
        topic:
            '''
            a = 1: 2
            y =
              'a': 'b'
              3:4

            z.y =
              'x': 4
              3 : 0

            '''

        'are allowed by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden': (source) ->
            config = no_implicit_braces: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 3)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Implicit braces are forbidden')
            assert.equal(error.rule, RULE)

            error = errors[1]
            assert.equal(error.lineNumber, 3)
            assert.equal(error.message, 'Implicit braces are forbidden')
            assert.equal(error.rule, RULE)

            error = errors[2]
            assert.equal(error.lineNumber, 7)
            assert.equal(error.message, 'Implicit braces are forbidden')
            assert.equal(error.rule, RULE)

    'Implicit braces strict':
        topic:
            '''
            foo =
              bar:
                baz: 1
                thing: 'a'
              baz: ['a', 'b', 'c']
            '''

        'blocks all implicit braces by default': (source) ->
            config = no_implicit_braces: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(rule, RULE) for { rule } in errors

        'allows braces at the end of lines when strict is false': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: false

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Implicit braces in class definitions':
        topic:
            '''
            class Animal
              walk: ->

            class Wolf extends Animal
              howl: ->

            class nested.Name
              constructor: (@options) ->

            class deeply.nested.Name
              constructor: (@options) ->

            x = class
              m: -> 123

            y = class extends x
              m: -> 456

            z = class

            r = class then 1:2
            '''

        'are always ignored': (source) ->
            config = no_implicit_braces: { level: 'error' }
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Test against use of implicit braces in loop with conditional (#459)':
        topic:
            '''
            list =
              count: 10
              items:
                for item in items
                  if not item
                    throw new Error 'Unexpected: falsy item in list!'

                  name: item.Name
                  age: item.Age
            '''

        'throws no errors for this when strict is false': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: false

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 0)

        'throws 2 errors when strict is true': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: true
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)


    'Test that any implicit braces inside classes are caught':
        topic: () ->
            '''
            class ABC
              @CONST = 'DEF'

              constructor: (abc) ->
                s =
                  t: 3

              getDef: ->
                u =
                  v: 'a'

            class A extends B
              @PI = 3

              constructor: ->
                @a = 3

            class Role extends Model
              @A = '1'
              @B = []
              @C = 3
              @D = {}

              constructor: (x) ->
                x = 5
                @E = 3

              eFunc: (f, g) ->
                g = @B * f
                return [@A, g]

            class Foo
              Object.defineProperty @::, 'bar', # err on strict: true
                enumerable: true
                get: ->
                  false

              toString: ->
                'foo'

            class X extends Y # this one should return no errors
              toString: ->
                'foo'

            class X extends A.B # check for . in class name.
              toString: ->
                'foo'
            '''

        'throws no errors for this when strict is false': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: false

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 0)

        'throws 3 errors for this when strict is true': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: true

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 3)

            assert.equal(errors[0].lineNumber, 6)
            assert.equal(errors[0].line, '      t: 3')

            assert.equal(errors[1].lineNumber, 10)
            assert.equal(errors[1].line, '      v: \'a\'')

            assert.equal(errors[2].lineNumber, 34)
            assert.equal(errors[2].line, '    enumerable: true')

    'Test Class with initial code in class being a defined function':
        topic: () ->
            '''
            class Foo

              privateFun = -> 42

              fun: -> privateFun()
            '''

        'should pass without errors': (source) ->

            config =
                no_implicit_braces:
                    level: 'error'
                    strict: true

            errors = coffeelint.lint(source, config)

            assert.isArray(errors)
            assert.lengthOf(errors, 0)

        'should pass without errors when strict=false': (source) ->

            config =
                no_implicit_braces:
                    level: 'error'
                    strict: false

            errors = coffeelint.lint(source, config)

            assert.isArray(errors)
            assert.lengthOf(errors, 0)

    'Test Class with @ in class name':
        topic: () ->
            '''
            class @A
              constructor: ->
                @X = @Y
            '''

        'should pass without errors': (source) ->

            config =
                no_implicit_braces:
                    level: 'error'
                    strict: true

            errors = coffeelint.lint(source, config)

            assert.isArray(errors)
            assert.lengthOf(errors, 0)

        'should pass without errors when strict=false': (source) ->

            config =
                no_implicit_braces:
                    level: 'error'
                    strict: false

            errors = coffeelint.lint(source, config)

            assert.isArray(errors)
            assert.lengthOf(errors, 0)

}).export(module)
