
regexes =
    trailingSemicolon : /;\r?$/

module.exports = class NoTrailingSemicolons

    rule:
        name: 'no_trailing_semicolons'
        level : 'error'
        message : 'Line contains a trailing semicolon'
        description: """
            This rule prohibits trailing semicolons, since they are needless
            cruft in CoffeeScript.
            <pre>
            <code># This semicolon is meaningful.
            x = '1234'; console.log(x)

            # This semicolon is redundant.
            alert('end of line');
            </code>
            </pre>
            Trailing semicolons are forbidden by default.
            """


    lintLine: (line, lineApi) ->
        hasSemicolon = regexes.trailingSemicolon.test(line)
        [first..., last] = lineApi.getLineTokens()
        hasNewLine = last and last.newLine?
        # Don't throw errors when the contents of  multiline strings,
        # regexes and the like end in ";"
        if hasSemicolon and not hasNewLine and lineApi.lineHasToken() and
                last[0] isnt 'STRING'
            return true
