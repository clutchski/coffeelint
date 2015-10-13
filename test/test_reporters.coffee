path = require 'path'
vows = require 'vows'
assert = require 'assert'

###
# # This will work from 3rd party code
# coffeelint = require 'coffeelint'
# RawReporter = require 'coffeelint/lib/reporters/raw'
###
coffeelint = require path.join('..', 'lib', 'coffeelint')
RawReporter = require path.join('..', 'lib', 'reporters', 'raw')
CSVReporter = require path.join('..', 'lib', 'reporters', 'csv')

class TestCSVReporter extends CSVReporter
    output = ''

    print: (input) ->
        output += input + '\r\n'

    publish: () ->
        super()
        output

class PassThroughReporter extends RawReporter
    print: (input) ->
        return JSON.parse(input)

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
            # Lint your files, no need to save the results. They're captured
            # inside the ErrorReport.
            errorReport.lint 'stdin', code

            # Construct a new reporter and publish the results. You can use the
            # built in reporters, or make your own.
            reporter = new PassThroughReporter errorReport
            result = reporter.publish()

            assert.equal(result.stdin.length, 1)
            error = result.stdin[0]
            assert.equal(error.name, 'indentation')

    'Make sure CSV is properly escaped':
        topic:
            '''
            class X
              y: ->
            '''

        'Make sure CSV columns are quoted, and newlines are escaped': (code) ->
            config =
                colon_assignment_spacing:
                    level: 'error'
                    spacing:
                        left: 0
                        right: 0

            errorReport = coffeelint.getErrorReport()
            errorReport.lint 'stdin', code, config

            # Construct a new reporter and publish the results. You can use the
            # built in reporters, or make your own.
            reporter = new TestCSVReporter errorReport
            result = reporter.publish().split(/\r?\n/)
            output = result[1].split(',')

            assert.equal(output[0], 'stdin')
            assert.equal(output[1], 2)
            assert.equal(output[2], '')
            assert.equal(output[3], 'error')
            context =
                '"Colon assignment without proper spacing Incorrect spacing ' +
                'around column 3.'

            assert.equal(output[4], context)
            assert.equal(result[2], 'Expected left: 0, right: 0.')
            assert.equal(result[3], 'Got left: 0, right: 1."')

}).export(module)
