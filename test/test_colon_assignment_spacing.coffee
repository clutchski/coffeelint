path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'colon_assignment_spacing'

vows.describe(RULE).addBatch({

    'Equal spacing around assignment':
        topic:
            '''
            object = {spacing : true}
            class Dog
              barks : true
            stringyObject =
              'stringkey' : 'ok'
            '''

        'will not return an error': (source) ->
            config =
                colon_assignment_spacing:
                    level: 'error'
                    spacing:
                        left: 1
                        right: 1
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'No space before assignment':
        topic:
            '''
            object = {spacing: true}
            object =
              spacing: true
            class Dog
              barks: true
            stringyObject =
              'stringkey': 'ok'
            '''

        'will not return an error': (source) ->
            config =
                colon_assignment_spacing:
                    level: 'error'
                    spacing:
                        left: 0
                        right: 1
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Newline to the right of assignment':
        topic:
            '''
            query:
              method: 'GET'
              isArray: false
            '''

        'will not return an error': (source) ->
            config =
                colon_assignment_spacing:
                    level: 'error'
                    spacing:
                        left: 0
                        right: 1
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Improper spacing around assignment':
        topic:
            '''
            object = {spacing: false}
            class Cat
              barks: false
            stringyObject =
              'stringkey': 'notcool'
            '''

        'will return an error': (source) ->
            config =
                colon_assignment_spacing:
                    level: 'error'
                    spacing:
                        left: 1
                        right: 1
            errors = coffeelint.lint(source, config)
            assert.equal(rule, RULE) for { rule } in errors
            assert.lengthOf(errors, 3)

        'will ignore an error': (source) ->
            config =
                colon_assignment_spacing:
                    level: 'ignore'
                    spacing:
                        left: 1
                        right: 1
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Should not complain about strings':
        topic:
            '''
            foo = (stuff) ->
              throw new Error("Error: stuff required") unless stuff?
              # do real work
            '''

        'will return an error': (source) ->
            config =
                colon_assignment_spacing:
                    level: 'error'
                    spacing:
                        left: 1
                        right: 1
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

}).export(module)
