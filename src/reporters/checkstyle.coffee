
JsLintReporter = require './jslint'

module.exports = class CheckstyleReporter

    constructor : (@errorReport, options = {}) ->

    print : (message) ->
        console.log message

    escape : JsLintReporter::escape

    publish : () ->
        @print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        @print "<checkstyle version=\"4.3\">"

        for path, errors of @errorReport.paths
            if errors.length
                @print "<file name=\"#{path}\">"

                for e in errors
                    level = e.level
                    level = 'warning' if level is 'warn'

                    # context is optional, this avoids generating the string
                    # "context: undefined"
                    context = e.context ? ""
                    @print """
                    <error line="#{e.lineNumber}"
                        severity="#{@escape(level)}"
                        message="#{@escape(e.message+'; context: '+context)}"
                        source="coffeelint"/>
                    """
                @print "</file>"

        @print "</checkstyle>"
