path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('no_unnecessary_fat_arrows').addBatch({

    'Single quotes' :

        topic : () ->
            '''
            foo = 'single'
            '''

        'single quotes should always be allowed' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)


    'Unnecessary double quotes' :

        topic : () ->
            '''
            foo = "double"
            '''

        'double quotes are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'double quotes can be forbidden' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Unnecessary double quotes are forbidden')
            assert.equal(error.rule, 'no_unnecessary_double_quotes')


    'Useful double quotes' :

        topic : () ->
            '''
            interpolation = "inter#{polation}"
            multipleInterpolation = "#{foo}bar#{baz}"
            singleQuote = "single'quote"
            '''

        'string interpolation should always be allowed' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)


    'Block strings with double quotes' :

        topic : () ->
            '''
            foo = """
              doubleblock
            """
            '''

        'block strings with double quotes are not allowed' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Unnecessary double quotes are forbidden')
            assert.equal(error.rule, 'no_unnecessary_double_quotes')


    'Block strings with useful double quotes' :

        topic : () ->
            '''
            foo = """
              #{interpolation}foo 'some single quotes for good measure'
            """
            '''

        'block strings with useful content should be allowed' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)


    'Block strings with single quotes' :

        topic : () ->
            """
            foo = '''
              singleblock
            '''
            """

        'block strings with single quotes should be allowed' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)


    'Hand concatenated string with parenthesis' :

        topic : () ->
            '''
            foo = (("inter") + "polation")
            '''

        'double quotes should not be allowed' : (source) ->
            config = {no_unnecessary_double_quotes : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Unnecessary double quotes are forbidden')
            assert.equal(error.rule, 'no_unnecessary_double_quotes')


}).export(module)
