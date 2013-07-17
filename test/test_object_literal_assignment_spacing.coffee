path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('objectliteralassignmentspacing').addBatch({

    'Spacing around assignment' :

        topic : -> '{spacing : true}'

        'will not return an error' : (source) ->
            config = {'object_literal_assignment_spacing' : 'error'}
            errors = coffeelint.link(source, config)
            assert.isEmpty(errors)

    'No spacing around assignment' :

        topic : -> '{spacing: false}'

        'will return an error' : (source) ->
            config = {'object_literal_assignment_spacing' : 'error'}
            errors = coffeelint.link(source, config)
            assert.equal(errors.length, 1)

        'will ignore an error' : (source) ->
            config = {'object_literal_assignment_spacing' : 'ignore'}
            errors = coffeelint.link(source, config)
            assert.isEmpty(errors)

}).export(module)