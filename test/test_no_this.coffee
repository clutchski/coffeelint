path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

configError = { no_this: { level: 'error' } }

RULE = 'no_this'

vows.describe(RULE).addBatch({

    'this':
        'should warn when \'this\' is used': ->
            result = coffeelint.lint('this.foo()', configError)[0]
            assert.equal(result.lineNumber, 1)
            assert.equal(result.rule, RULE)

    '@':
        'should not warn when \'@\' is used': ->
            assert.isEmpty(coffeelint.lint('@foo()', configError))

    'Comments':
        topic:
            '''
            # this.foo()
            ###
            this.foo()
            ###
            '''

        'should not warn when \'this\' is used in a comment': (source) ->
            assert.isEmpty(coffeelint.lint(source, configError))

    'Strings':
        'should not warn when \'this\' is used in a single-quote string': ->
            assert.isEmpty(coffeelint.lint('\'this.foo()\'', configError))

        'should not warn when \'this\' is used in a double-quote string': ->
            assert.isEmpty(coffeelint.lint('"this.foo()"', configError))

        'should not warn when \'this\' is used in a multiline string': ->
            source = '''
                """
                this.foo()
                """
            '''
            assert.isEmpty(coffeelint.lint(source, configError))

    'Compatibility with no_stand_alone_at':
        topic:
            '''
            class X
              constructor: ->
                this

            class Y extends X
              constructor: ->
                this.hello

            '''

        'returns an error if no_stand_alone_at is on ignore': (source) ->
            config =
                no_stand_alone_at:
                    level: 'ignore'
                no_this:
                    level: 'error'

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 3)
            assert.equal(error.rule, RULE)

            error = errors[1]
            assert.equal(error.lineNumber, 7)
            assert.equal(error.rule, RULE)

        'returns no errors if no_stand_alone_at is on warn/error': (source) ->
            config =
                no_stand_alone_at:
                    level: 'warn'
                no_this:
                    level: 'error'

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)

            error = errors[0]
            assert.equal(error.lineNumber, 7)
            assert.equal(error.rule, RULE)

            config =
                no_stand_alone_at:
                    level: 'error'
                no_this:
                    level: 'error'

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)

            error = errors[0]
            assert.equal(error.lineNumber, 7)
            assert.equal(error.rule, RULE)

}).export(module)
