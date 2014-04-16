
regexes =
    literateComment: ///
        ^
        \#\s # This is prefixed on MarkDown lines.
    ///
    longUrlComment : ///
      ^\s*\# # indentation, up to comment
      \s*
      http[^\s]+$ # Link that takes up the rest of the line without spaces.
    ///

module.exports = class MaxLineLength

    rule:
        name: 'max_line_length'
        value: 80
        level : 'error'
        limitComments: true
        message : 'Line exceeds maximum allowed length'
        description: """
            This rule imposes a maximum line length on your code. <a
            href="http://www.python.org/dev/peps/pep-0008/">Python's style
            guide</a> does a good job explaining why you might want to limit the
            length of your lines, though this is a matter of taste.

            Lines can be no longer than eighty characters by default.
            """

    lintLine: (line, lineApi) ->
        max = lineApi.config[@rule.name]?.value
        limitComments = lineApi.config[@rule.name]?.limitComments

        lineLength = line.trimRight().length
        if lineApi.isLiterate() and regexes.literateComment.test(line)
            lineLength -= 2

        if max and max < lineLength and not regexes.longUrlComment.test(line)

            unless limitComments
                if lineApi.getLineTokens().length is 0
                    return

            return {
                context: "Length is #{lineLength}, max is #{max}"
            }
