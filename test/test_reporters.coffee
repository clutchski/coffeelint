path = require 'path'
vows = require 'vows'
assert = require 'assert'

###
# # This will work from 3rd party code
# coffeelint = require 'coffeelint'
# RawReporter = require 'coffeelint/lib/reporters/raw'
###

coffeelint = require path.join('..', 'lib', 'coffeelint')
PassThroughReporter = require path.join('..', 'lib', 'reporters', 'passthrough')

vows.describe('reporters').addBatch({

    'Can be used by 3rd party projects':
        topic:
            '''
            if true
                undefined
            '''

        '(example)': (code) ->

            # Grab your own ErrorReport
            errorReport = coffeelint.getErrorReport()
            # Lint your files, no need to save the results.
            # They're captured inside the ErrorReport.
            errorReport.lint 'stdin', code

            # Construct a new reporter and publish the results.
            # You can use the built in reporters, or make your own.
            reporter = new PassThroughReporter errorReport
            result = reporter.publish()

            assert.equal(result.stdin.length, 1)
            error = result.stdin[0]
            assert.equal(error.name, 'indentation')

}).export(module)
