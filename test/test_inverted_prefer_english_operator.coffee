path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

configError =
  prefer_english_operator:
    level: 'error'
    invert: true

vows.describe('InvertedPreferEnglishOperators').addBatch({

    'non-English operators':
        'should not warn when == is used': ->
            result = coffeelint.lint('1 == 1', configError)
            assert.isEmpty(result)

        'should not warn when != is used': ->
            result = coffeelint.lint('1 != 1', configError)
            assert.isEmpty(result)

        'should not warn when && is used': ->
            result = coffeelint.lint('1 && 1', configError)
            assert.isEmpty(result)

        'should not warn when || is used': ->
            result = coffeelint.lint('1 || 1', configError)
            assert.isEmpty(result)

        'should not warn when ! is used': ->
            result = coffeelint.lint('x = !y', configError)
            assert.isEmpty(result)

    'double not (!!)':
        'is ignored by default': ->
            result = coffeelint.lint('x = !!y', configError)
            assert.equal(result.length, 0)

        'cannot be configured at an independent level (invert wins over doubleNotLevel)': ->

            configError = prefer_english_operator:
                level: 'error'
                doubleNotLevel: 'warn'
                invert: true

            result = coffeelint.lint('x = !!y', configError)
            assert.equal(result.length, 0)

    'English operators':
        'should warn when \'is\' is used': ->
            result = coffeelint.lint('1 is 1', configError)[0]
            assert.equal result?.context, 'Replace "is" with "=="'

        'should warn when \'isnt\' is used': ->
            result = coffeelint.lint('1 isnt 1', configError)[0]
            assert.equal result?.context, 'Replace "isnt" with "!="'

        'should warn when \'and\' is used': ->
            result = coffeelint.lint('1 and 1', configError)[0]
            assert.equal result?.context, 'Replace "and" with "&&"'

        'should warn when \'or\' is used': ->
            result = coffeelint.lint('1 or 1', configError)[0]
            assert.equal result?.context, 'Replace "or" with "||"'

    'Comments': ->
        topic: """
        # 1 is 1
        # 1 isnt 1
        # 1 and 1
        # 1 or 1
        ###
        1 is 1
        1 isnt 1
        1 and 1
        1 or 1
        ###
        """
        'should not warn when is is used in a comment': (source) ->
            assert.isEmpty(coffeelint.lint(source, configError))

    'Strings':
        'should not warn when is is used in a single-quote string': ->
            assert.isEmpty(coffeelint.lint('\'1 is 1\'', configError))

        'should not warn when is is used in a double-quote string': ->
            assert.isEmpty(coffeelint.lint('"1 is 1"', configError))

        'should not warn when is is used in a multiline string': ->
            source = '''
                """
                1 is 1
                """
            '''
            assert.isEmpty(coffeelint.lint(source, configError))

}).export(module)
