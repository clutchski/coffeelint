
regexes =
    trailingWhitespace : /[^\s]+[\t ]+\r?$/
    onlySpaces: /^[\t ]+\r?$/
    lineHasComment : /^\s*[^\#]*\#/

module.exports = class NoTrailingWhitespace

    rule:
        name: 'no_trailing_whitespace'
        level : 'error'
        message : 'Line ends with trailing whitespace'
        allowed_in_comments : false
        allowed_in_empty_lines: true
        description: """
            This rule forbids trailing whitespace in your code, since it is
            needless cruft. It is enabled by default.
            """

    lintLine: (line, lineApi) ->
        unless lineApi.config['no_trailing_whitespace']?.allowed_in_empty_lines
            if regexes.onlySpaces.test(line)
                return true

        if regexes.trailingWhitespace.test(line)
            # By default only the regex above is needed.
            unless lineApi.config['no_trailing_whitespace']?.allowed_in_comments
                return true

            line = line
            tokens = lineApi.tokensByLine[lineApi.lineNumber]

            # If we're in a block comment there won't be any tokens on this
            # line. Some previous line holds the token spanning multiple lines.
            if !tokens
                return null

            # To avoid confusion when a string might contain a "#", every string
            # on this line will be removed. before checking for a comment
            for str in (token[1] for token in tokens when token[0] == 'STRING')
                line = line.replace(str, 'STRING')

            if !regexes.lineHasComment.test(line)
                return true
