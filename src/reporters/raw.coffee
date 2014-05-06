module.exports = class RawReporter

    constructor : (@errorReport, options = {}) ->

    print : (message) ->
        console.log message

    publish : () ->
        @print JSON.stringify(@errorReport.paths, undefined, 2)

