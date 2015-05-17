path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

configError = {no_this: {level: 'error'}}

vows.describe('no_this').addBatch({

    'this':
        'should warn when \'this\' is used': ->
            result = coffeelint.lint('this.foo()', configError)[0]
            assert.equal(result.lineNumber, 1)
            assert.equal(result.rule, 'no_this')

    '@':
        'should not warn when \'@\' is used': ->
            assert.isEmpty(coffeelint.lint('@foo()', configError))

    'Comments': ->
        topic: """
        # this.foo()
        ###
        this.foo()
        ###
        """
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

}).export(module)
