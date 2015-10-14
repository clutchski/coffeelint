module.exports = class RawReporter

    constructor: (@errorReport, options = {}) ->

    print: (message) ->
        # coffeelint: disable=no_debugger
        console.log message
        # coffeelint: enable=no_debugger

    publish: () ->
        @print JSON.stringify(@errorReport.paths, undefined, 2)
