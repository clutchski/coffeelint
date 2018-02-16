indentationRegex = /\S/

module.exports = class NoSpaces

    rule:
        name: 'no_spaces'
        level: 'ignore'
        message: 'Line contains space indentation'
        description: '''
            This rule forbids spaces in indentation. It is disabled by default.
            '''

    lintLine: (line, lineApi) ->
        # Only check lines that have compiled tokens. This helps
        # us ignore spaces in the middle of multi line strings, heredocs, etc.
        # since they are all reduced to a single token whose line number
        # is the start of the expression.
        indentation = line.split(indentationRegex)[0]
        if lineApi.lineHasToken() and '\ ' in indentation
            true
        else
            null
