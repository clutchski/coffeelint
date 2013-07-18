path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('colonassignmentspacing').addBatch({

    'Spacing around assignment' :

        topic : ->
            '''
            object = {spacing : true}
            class Dog
              barks : true
            stringyObject =
              'stringkey' : 'ok'
            newlineObject =
              obj :
                key : 'value'
            '''

        'will not return an error' : (source) ->
            config = 'colon_assignment_spacing' : {'level' : 'error'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'No spacing around assignment' :

        topic : ->
            '''
            object = {spacing: false}
            class Cat
              barks: false
            stringyObject =
              'stringkey': 'notcool'
            '''

        'will return an error' : (source) ->
            config = 'colon_assignment_spacing' : {'level' : 'error'}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 3)

        'will ignore an error' : (source) ->
            config = 'colon_assignment_spacing' : {'level' : 'ignore'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Should not complain about strings' :

        topic : ->
            '''
            foo = (stuff) ->
              throw new Error("Error: stuff required") unless stuff?
              # do real work
            '''

        'will return an error' : (source) ->
            config = 'colon_assignment_spacing' : {'level' : 'error'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

}).export(module)