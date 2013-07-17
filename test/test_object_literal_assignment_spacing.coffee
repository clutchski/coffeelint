path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('objectassignmentspacing').addBatch({

    'Spacing around assignment' :

        topic : ->
            '''
            object = {spacing : true}
            '''

        'will not return an error' : (source) ->
            config = 'object_assignment_spacing' : {'level' : 'error'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'No spacing around assignment' :

        topic : ->
            '''
            object = {spacing: false}
            '''

        'will return an error' : (source) ->
            config = 'object_assignment_spacing' : {'level' : 'error'}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)

        'will ignore an error' : (source) ->
            config = 'object_assignment_spacing' : {'level' : 'ignore'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

}).export(module)