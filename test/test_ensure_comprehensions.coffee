path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

ruleName = 'ensure_comprehensions'
errorMessage = 'Comprehensions must have parentheses around them'
config = {}

vows.describe(ruleName).addBatch({

    'Ignore for-loops':
        topic:
            '''
            y = y + 5

            for x in xlist
              console.log x

            if a is b
              for x in xlist
                console.log x
            '''

        'are ignored' : (source) ->
            config[ruleName] = { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'When forgetting parens':
        topic:
            '''
            for x in xlist
              console.log x

            doubleIt = x * 2 for x in singles

            if a is b
              for x in xlist
                console.log x
            '''

        'throws an error': (source) ->
            config[ruleName] = { level: 'error' }

            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)

            error = errors[0]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.message, errorMessage)
            assert.equal(error.rule, ruleName)

        'doesn\'t throw an error when rule is ignore': (source) ->
            config[ruleName] = { level: 'ignore' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Doesn\'t trigger if we encounter key/value of the loop before equal sign':
        topic:
            '''
            sum = 0
            nums = [1, 2, 3, 4, 5]
            for n in nums
              sum += n

            sum = n for n in nums # error triggers without parens

            # this triggers for lack of parens as well
            x = y(food) for food in foods when food isnt 'chocolate'

            # this shouldn't trigger
            yak(food) for food in foods when food isnt 'chocolate'

            newConfig[key] = value for key, value of config
            '''

        'doesn\'t throw an error': (source) ->
            config[ruleName] = { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)

            error = errors[0]
            assert.equal(error.lineNumber, 6)
            assert.equal(error.message, errorMessage)
            assert.equal(error.rule, ruleName)

            error = errors[1]
            assert.equal(error.lineNumber, 9)
            assert.equal(error.message, errorMessage)
            assert.equal(error.rule, ruleName)

    'Doesn\'t trigger if we encounter key/value and there is no equal sign':
        topic:
            '''
            sum = 0
            nums = [1, 2, 3, 4, 5]
            for n in nums
              sum += n

            sum += n for n in nums

            eat food for food in foods when food isnt 'chocolate'
            '''

        'doesn\'t throw an error': (source) ->
            config[ruleName] = { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Doesn\'t trigger when variable is set to a for-loop with a block':
        topic:
            '''
            myLines = for row in [start..end]
              if row[start] is ' '
                line = true
              else
                line = false
              line
            '''

        'doesn\'t throw an error': (source) ->
            config[ruleName] = { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Functions return all comprehensions as an array':
        topic:
            '''
            myLines = ->
              (row[start] + "!" for row in [start..end])

            myLines = ->
              row[start] + "!" for row in [start..end]

            myLines = -> row[start] + "!" for row in [start..end]

            myLines = -> (row[start] + "!" for row in [start..end])

            '''

        'doesn\'t throw an error': (source) ->
            config[ruleName] = { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Comprehensions that are called as a function parameter should not error':
        topic:
            '''
            b = a(food for food in foods when food isnt 'chocolate')
            '''

        'doesn\'t throw an error': (source) ->
            config[ruleName] = { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

}).export(module)
