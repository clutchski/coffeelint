path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'max_line_length'
vows.describe(RULE).addBatch({

    'Maximum line length':
        topic: () ->
            # Every line generated here is a comment.
            line = (length) ->
                return '# ' + new Array(length - 1).join('-')
            lengths = [50, 79, 80, 81, 100, 200]
            (line(l) for l in lengths).join('\n')

        'defaults to 80': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 3)
            error = errors[0]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.message, 'Line exceeds maximum allowed length')
            assert.equal(error.rule, RULE)

        'is configurable': (source) ->
            config =
                max_line_length:
                    value: 99
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)

        'is optional': (source) ->
            for length in [null, 0, false]
                config =
                    max_line_length:
                        value: length
                        level: 'ignore'
                errors = coffeelint.lint(source, config)
                assert.isEmpty(errors)

        'can ignore comments': (source) ->
            config =
                max_line_length:
                    limitComments: false

            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

        'respects Windows line breaks': ->
            source = new Array(81).join('X') + '\r\n'

            errors = coffeelint.lint(source, {})
            assert.isEmpty(errors)

    'Literate Line Length':
        topic: ->
            # This creates a line with 80 Xs.
            source = new Array(81).join('X') + '\n'

            # Long URLs are ignored by default even in Literate code.
            source += 'http://testing.example.com/really-really-long-url-' +
                'that-shouldnt-have-to-be-split-to-avoid-the-lint-error'

        'long urls are ignored': (source) ->
            errors = coffeelint.lint(source, {}, true)
            assert.isEmpty(errors)

    'Maximum length exceptions':
        topic:
            '''
            # Since the line length check only reads lines in isolation it will
            # see the following line as a comment even though it's in a string.
            # I don't think that's a problem.
            #
            # http://testing.example.com/really-really-long-url-that-shouldnt-have-to-be-split-to-avoid-the-lint-error
            '''

        'excludes long urls': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

}).export(module)
