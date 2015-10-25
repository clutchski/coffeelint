path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

configError = no_trailing_semicolons: { level: 'error' }
configIgnore = no_trailing_semicolons: { level: 'ignore' }

RULE = 'no_trailing_semicolons'

vows.describe(RULE).addBatch({

    'Semicolons at end of lines':
        topic:
            '''
            x = 1234;
            y = 1234; z = 1234
            '''

        'are forbidden': (source) ->
            errors = coffeelint.lint(source)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line contains a trailing semicolon')
            assert.equal(error.rule, RULE)

        'can be ignored': (source) ->
            errors = coffeelint.lint(source, configIgnore)
            assert.isEmpty(errors)

    'Semicolons in multiline expressions':
        topic:
            '''
            x = "asdf;
            asdf"

            y1 = """
            #{asdf1};
            _#{asdf2}_;
            asdf;
            """

            y2 = """
                #{asdf1};
                _#{asdf2}_;
                asdf;
            """

            z = ///
            a*\;
            ///
            '''

        'are ignored': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Trailing semicolon in comments':
        topic:
            '''
            undefined\n# comment;\nundefined
            '''

        'are ignored': (source) ->
            errors = coffeelint.lint(source, {})
            assert.isEmpty(errors)

    'Trailing semicolon in comments with no semicolon in statement':
        topic:
            '''
            x = 3 #set x to 3;
            '''

        'are ignored': (source) ->
            errors = coffeelint.lint(source, configIgnore)
            assert.isEmpty(errors)

        'will throw an error': (source) ->
            errors = coffeelint.lint(source, configError)
            assert.isEmpty(errors)

    'Trailing semicolon in comments with semicolon in statement':
        topic:
            '''
            x = 3; #set x to 3;
            '''

        'are ignored': (source) ->
            errors = coffeelint.lint(source, configIgnore)
            assert.isEmpty(errors)

        'will throw an error': (source) ->
            errors = coffeelint.lint(source, configError)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line contains a trailing semicolon')
            assert.equal(error.rule, RULE)

    'Trailing semicolon in block comments':
        topic:
            '''
            ###\nThis is a block comment;\n###
            '''

        'are ignored': (source) ->
            errors = coffeelint.lint(source, configIgnore)
            assert.isEmpty(errors)

        'are ignored even if config level is error': (source) ->
            errors = coffeelint.lint(source, configError)
            assert.isEmpty(errors)

    'Semicolons with windows line endings':
        topic:
            '''
            x = 1234;\r\n
            '''

        'works as expected': (source) ->
            config = line_endings: { value: 'windows' }
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line contains a trailing semicolon')
            assert.equal(error.rule, RULE)

    'Semicolons inside of blockquote string':
        topic:
            '''
            foo = bar();

            errs = """
              this does not err;
              this does;
              #{isEmpty a};
              #{isEmpty(b)};
            """

            nothing = """
            this does not err;
            this neither;
            #{isEmpty(x)};
            #{isEmpty y};
            """
            '''

        'are ignored': (source) ->
            errors = coffeelint.lint(source, configError)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line contains a trailing semicolon')
            assert.equal(error.rule, RULE)

}).export(module)
