path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('transform').addBatch({

    'transform' :

        topic : () ->
            """
            a = 1
            """

        'are used to transform the source' : (source) ->
            calls = 0

            config = {
                transform : [
                    (source) ->
                        calls = calls + 1
                        source
                ]
            }

            coffeelint.lint(source, config)
            assert.equal(calls, 1)

}).export(module)
