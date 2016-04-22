module.exports = class RawReporter

    constructor: (@errorReport, options = {}) ->
        { @quiet } = options

    print: (message) ->
        # coffeelint: disable=no_debugger
        console.log message
        # coffeelint: enable=no_debugger

    publish: () ->
        er = {}
        for path, errors of @errorReport.paths
            er[path] = (e for e in errors when not @quiet or e.level is 'error')

        @print JSON.stringify(er, undefined, 2)
