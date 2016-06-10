path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_stand_alone_at'

vows.describe(RULE).addBatch({

    'Stand alone @':
        topic:
            '''
            @alright
            @   .error
            @ok()
            @ notok
            @[ok]
            @.ok
            not(@).ok
            @::ok
            @:: #notok
            @(fn)
            '''

        'are allowed by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden': (source) ->
            config = no_stand_alone_at: { level: 'error' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 3)
            error = errors[0]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.rule, RULE)
            error = errors[1]
            assert.equal(error.lineNumber, 7)
            assert.equal(error.rule, RULE)
            error = errors[2]
            assert.equal(error.lineNumber, 9)
            assert.equal(error.rule, RULE)

}).export(module)
