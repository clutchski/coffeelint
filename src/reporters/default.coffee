
# Reports errors to the command line.
module.exports = class Reporter

    constructor : (@errorReport, options = {}) ->
        {
            colorize
            @quiet
        } = options
        colorize ?= true
        @colorize = colorize and process.stdout.isTTY
        @ok = '✓'
        @warn = '⚡'
        @err = '✗'

    stylize : (message, styles...) ->
        return message if not @colorize
        map = {
            bold  : [1,  22],
            yellow: [33, 39],
            green: [32, 39],
            red: [31, 39]
        }
        return styles.reduce (m, s)  ->
            return "\u001b[" + map[s][0] + "m" + m + "\u001b[" + map[s][1] + "m"
        , message

    publish : () ->
        paths = @errorReport.paths

        report  = ""
        report += @reportPath(path, errors) for path, errors of paths
        report += @reportSummary(@errorReport.getSummary())
        report += ""

        @print report if not @quiet or @errorReport.hasError()
        return this

    reportSummary : (s) ->
        start = if s.errorCount > 0
            "#{@err} #{@stylize("Lint!", 'red', 'bold')}"
        else if s.warningCount > 0
            "#{@warn} #{@stylize("Warning!", 'yellow', 'bold')}"
        else
            "#{@ok} #{@stylize("Ok!", 'green', 'bold')}"
        e = s.errorCount
        w = s.warningCount
        p = s.pathCount
        err = @plural('error', e)
        warn = @plural('warning', w)
        file = @plural('file', p)
        msg = "#{start} » #{e} #{err} and #{w} #{warn} in #{p} #{file}"
        return "\n" + @stylize(msg) + "\n"

    reportPath : (path, errors) ->
        [overall, color] = if hasError = @errorReport.pathHasError(path)
            [@err, 'red']
        else if hasWarning = @errorReport.pathHasWarning(path)
            [@warn, 'yellow']
        else
            [@ok, 'green']

        pathReport = ""
        if not @quiet or hasError
            pathReport += "  #{overall} #{@stylize(path, color, 'bold')}\n"

        for e in errors
            continue if @quiet and e.level != 'error'
            o = if e.level == 'error' then @err else @warn
            lineEnd = ""
            lineEnd = "-#{e.lineNumberEnd}" if e.lineNumberEnd?
            output = "#" + e.lineNumber + lineEnd

            pathReport += "     " +
                "#{o} #{@stylize(output, color)}: #{e.message}."
            pathReport += " #{e.context}." if e.context
            pathReport += "\n"

        pathReport

    print : (message) ->
        console.log message

    plural : (str, count) ->
        if count == 1 then str else "#{str}s"

