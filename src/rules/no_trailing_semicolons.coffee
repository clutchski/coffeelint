
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

        # The TERMINATOR token is extended through to the next token. As a
        # result a line with a comment DOES have a token: the TERMINATOR from
        # the last line of code.
        lineTokens = lineApi.getLineTokens()
        if lineTokens.length is 1 and lineTokens[0][0] in ['TERMINATOR', 'HERECOMMENT']
            return

        newLine = line
        if lineTokens.length > 1 and lineTokens[lineTokens.length - 1][0] is 'TERMINATOR'

            # startPos contains the end position of the last non-TERMINATOR token
            # endPos contains the start position of the TERMINATOR token
            # if startPos and endPos arent equal, that probably means a comment
            # was sliced out of the tokenizer

            startPos = lineTokens[lineTokens.length - 2][2].last_column + 1
            endPos = lineTokens[lineTokens.length - 1][2].first_column
            if (startPos isnt endPos)
                startCounter = startPos
                while line[startCounter] isnt "#" and startCounter < line.length
                    startCounter++
                newLine = line.substring(0, startCounter).replace(/\s*$/, '')

        hasSemicolon = regexes.trailingSemicolon.test(newLine)
        [first..., last] = lineTokens
        hasNewLine = last and last.newLine?
        # Don't throw errors when the contents of  multiline strings,
        # regexes and the like end in ";"
        if hasSemicolon and not hasNewLine and lineApi.lineHasToken() and
                not (last[0] in ['STRING', 'IDENTIFIER'])
            return true
