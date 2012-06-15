path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('return').addBatch({

    'Implicit returns' :

        topic : () ->
            '''
            double = (x) ->
              x*2

            triple = (x) ->
              return x*3

            noop = ->

            complex = (x) ->
              x += 2
              x -= 5
              x = x * 4
              x / 2

            class Cat
              constructor: ->
                @howhigh = 5
              roar: -> return 'meow'
              jump: => @howhigh
            '''

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {no_implicit_return : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 3)
            for error in errors
                assert.equal(error.message, 'Implicit returns are forbidden')
                assert.equal(error.rule, 'no_implicit_return')

            assert.deepEqual(errors.map((e) -> e.context),
                             ['double', 'complex', 'jump'])

}).export(module)
