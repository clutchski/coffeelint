path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'spacing_after_comma'

vows.describe(RULE).addBatch({

    'regex':
        topic:
            '''
            ///^#{ inputValue }///i.test field.name
            '''

        'should not error': (source) ->
            config = { spacing_after_comma: { level: 'warn' } }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'Whitespace after commas':
        topic:
            '''
            doSomething(foo = ',',bar)\nfooBar()
            '''

        'permitted by default': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 0)

        'can be forbidden': (source) ->
            config = { spacing_after_comma: { level: 'warn' } }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'a space is required after commas')
            assert.equal(error.rule, RULE)

    'newline after commas':
        topic:
            '''
            multiLineFuncCall(
              arg1,
              arg2,
              arg3
            )
            '''

        'should not issue warns': (source) ->
            config = { spacing_after_comma: { level: 'warn' } }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

}).export(module)
