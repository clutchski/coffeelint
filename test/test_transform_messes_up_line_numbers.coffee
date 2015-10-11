path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

fs = require('fs')
thisdir = path.dirname(fs.realpathSync(__filename))

prefix = path.join(thisdir, 'fixtures', 'prefix_transform.coffee')
cloud = path.join(thisdir, 'fixtures', 'cloud_transform.coffee')

vows.describe('transform_messes_up_line_numbers').addBatch({

    'transform_messes_up_line_numbers':
        topic:
            '''
            console.log('Hello cloud')
            '''

        'will warn if the number of lines changes': (source) ->
            config =
                coffeelint:
                    transforms: [prefix, cloud]

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            assert.equal(errors[0].name, 'transform_messes_up_line_numbers')

        "will not warn if the number of lines doesn't change": (source) ->
            config =
                coffeelint:
                    transforms: [cloud]

            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

}).export(module)
