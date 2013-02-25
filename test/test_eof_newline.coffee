path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')
rule = 'no_eof_newline'
vows.describe('eof newline').addBatch({

    'Empty file without EOF new line' :

        topic : ""

        'can be error' : (source) ->
            config = {}
            config[rule] = {level:'error'}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, rule)

        'is permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'EOF without newline' :

        topic : "x+y\nb+x\nc+d"

        'can be error' : (source) ->
            config = {}
            config[rule] = {level:'error'}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, rule)

        'is permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'EOF with newline' :

        topic : "x+y\nb+x\nc+d\n"

        'is good' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

}).export(module)

