module.exports = class CSVReporter

    constructor: (@errorReport, options = {}) ->
        { @quiet } = options

    print: (message) ->
        # coffeelint: disable=no_debugger
        console.log message
        # coffeelint: enable=no_debugger

    publish: () ->
        header = ['path', 'lineNumber', 'lineNumberEnd', 'level', 'message']
        @print header.join(',')
        for path, errors of @errorReport.paths
            for e in errors when not @quiet or e.level is 'error'
                # Having the context is useful for the cyclomatic_complexity
                # rule and critical for the undefined_variables rule.
                e.message += " #{e.context}." if e.context
                f = [
                    path
                    e.lineNumber
                    e.lineNumberEnd ? e.lineNumberEnd
                    e.level
                    e.message
                ]
                @print f.join(',')
