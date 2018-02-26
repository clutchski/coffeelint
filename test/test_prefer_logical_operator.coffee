path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

configError = { prefer_logical_operator: { level: 'error' } }

RULE = 'prefer_logical_operator'

vows.describe(RULE).addBatch({

    'English operators':
        'should warn when \'is\' is used': ->
            result = coffeelint.lint('1 is 1', configError)[0]
            assert.equal result.context, 'Replace "is" with "=="'

        'should warn when \'isnt\' is used': ->
            result = coffeelint.lint('1 isnt 1', configError)[0]
            assert.equal result.context, 'Replace "isnt" with "!="'

        'should warn when \'and\' is used': ->
            result = coffeelint.lint('1 and 1', configError)[0]
            assert.equal result.context, 'Replace "and" with "&&"'

        'should warn when \'or\' is used': ->
            result = coffeelint.lint('1 or 1', configError)[0]
            assert.equal result.context, 'Replace "or" with "||"'

        'should warn when \'or=\' is used': ->
            result = coffeelint.lint('a or= 1', configError)[0]
            assert.equal result.context, 'Replace "or" with "||"'

        'should warn when \'not\' is used': ->
            result = coffeelint.lint('x = not 1', configError)[0]
            assert.equal result.context, 'Replace "not" with "!"'

        'should warn when \'yes\' is used': ->
            result = coffeelint.lint('a = 1 || yes', configError)[0]
            assert.equal result.context, 'Replace "yes" with true'

        'should warn when \'on\' is used': ->
            result = coffeelint.lint('a = 1 || on', configError)[0]
            assert.equal result.context, 'Replace "on" with true'

        'should warn when \'no\' is used': ->
            result = coffeelint.lint('a = 1 || no', configError)[0]
            assert.equal result.context, 'Replace "no" with false'

        'should warn when \'off\' is used': ->
            result = coffeelint.lint('a = 1 || off', configError)[0]
            assert.equal result.context, 'Replace "off" with false'

    'Logical operators':
        'should not warn when \'==\' is used': ->
            assert.isEmpty(coffeelint.lint('1 == 1', configError))

        'should not warn when \'!=\' is used': ->
            assert.isEmpty(coffeelint.lint('1 != 1', configError))

        'should not warn when \'&&\' is used': ->
            assert.isEmpty(coffeelint.lint('1 && 1', configError))

        'should not warn when \'||\' is used': ->
            assert.isEmpty(coffeelint.lint('1 || 1', configError))

        'should not warn when \'!\' is used': ->
            assert.isEmpty(coffeelint.lint('x = !1', configError))

        'should not warn when \'true\' is used': ->
            assert.isEmpty(coffeelint.lint('a = 1 || true', configError))

        'should not warn when \'false\' is used': ->
            assert.isEmpty(coffeelint.lint('a = 1 || false', configError))

    'Comments': ->
        topic:
            '''
            # 1 is 1
            # 1 isnt 1
            # 1 and 1
            # 1 or 1
            # a = not 1
            # a = 1 or yes
            # a = 1 or on
            # a = 1 and no
            # a = 1 and yes
            ###
            1 is 1
            1 isnt 1
            1 and 1
            1 or 1
            a = not 1
            a = 1 or yes
            a = 1 or on
            a = 1 and no
            a = 1 and yes
            ###
            '''

        'should not warn when == is used in a comment': (source) ->
            assert.isEmpty(coffeelint.lint(source, configError))

    'Strings':
        'should not warn when \'or\' is used in a single-quote string': ->
            assert.isEmpty(coffeelint.lint('\'1 or 1\'', configError))

        'should not warn when \'or\' is used in a double-quote string': ->
            assert.isEmpty(coffeelint.lint('"1 or 1"', configError))

        'should not warn when \'or\' is used in a multiline string': ->
            source = '''
                """
                1 or 1
                """
                '''
            assert.isEmpty(coffeelint.lint(source, configError))

        'should warn when \'or\' is used inside string interpolation': ->
            result = coffeelint.lint('a = "#{1 or 1}"', configError)[0]
            assert.equal result.context, 'Replace "or" with "||"'

}).export(module)
