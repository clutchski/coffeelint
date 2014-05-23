path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('no variable overwrite in for loops').addBatch({

    'variable overwrite in for loops' :

        topic : () ->
            """
            os = require 'os'
            path = require 'path'
            foo = () ->
              for path in [1, 2, 3] # not ok
                null
            foo()
            console.log path.join 'a', 'b' # throws
            oses = ['osx', 'dos']
            for os in oses
              console.log os
            console.log os.hostname()
            """

        'is allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config =
                no_for_overwrite:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.rule, 'no_for_overwrite')
            error = errors[1]
            assert.equal(error.lineNumber, 9)
            assert.equal(error.rule, 'no_for_overwrite')

}).export(module)
