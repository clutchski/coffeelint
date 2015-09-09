path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

alphabetizeKeysConfig = {alphabetize_keys: {level: 'error'}}

vows.describe('Alphabetize Keys').addBatch({

    'disabled by default' :
        'with keys not in alphabetical order' :
            topic : """
                object =
                    keyC: 3
                    keyB: 2
                    keyA: 1
                """

            'should not error' : (source) ->
                errors = coffeelint.lint source
                assert.equal errors.length, 0

    'defining an object' :
        'with keys in alphabetical order' :
            topic : """
                object =
                    keyA: 1
                    keyB: 2
                    keyC: 3
                """

            'should not error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 0

        'with nested keys in alphabetical order' :
            topic : """
                object =
                    keyA:
                      keyD: 4
                      keyE: 5
                      keyF: 6
                    keyB: 2
                    keyC: 3
                """

            'should not error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 0

        'with keys not in alphabetical order' :
            topic : """
                object =
                    keyC: 3
                    keyB: 2
                    keyA: 1
                """

            'should error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 1
                assert.equal errors[0].rule,  'alphabetize_keys'

        'with nested keys not in alphabetical order' :
            topic : """
                object =
                    keyA:
                      keyF: 6
                      keyE: 5
                      keyD: 4
                    keyB: 2
                    keyC: 3
                """

            'should error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 1
                assert.equal errors[0].rule,  'alphabetize_keys'

    'destructing an object' :
        'with keys in alphabetical order' :
            topic : """
                {keyA, keyB, keyC} = object
                """

            'should not error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 0

        'with keys not in alphabetical order' :
            topic : """
                {keyC, keyB, keyA} = object
                """

            'should error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 1
                assert.equal errors[0].rule,  'alphabetize_keys'

    'destructing an argument' :
        'with keys in alphabetical order' :
            topic : """
                fn = ({keyA, keyB, keyC}) ->
                """

            'should not error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 0

        'with keys not in alphabetical order' :
            topic : """
                fn = ({keyC, keyB, keyA}) ->
                """

            'should error' : (source) ->
                errors = coffeelint.lint source, alphabetizeKeysConfig
                assert.equal errors.length, 1
                assert.equal errors[0].rule,  'alphabetize_keys'


}).export(module)

