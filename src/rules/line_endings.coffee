

module.exports = class LineEndings

    rule:
        name: 'line_endings'
        level : 'ignore'
        value : 'unix' # or 'windows'
        message : 'Line contains incorrect line endings'
        description: """
            This rule ensures your project uses only <tt>windows</tt> or
            <tt>unix</tt> line endings. This rule is disabled by default.
            """

    lintLine: (line, lineApi) ->
        ending = lineApi.config[@rule.name]?.value

        return null if not ending or lineApi.isLastLine() or not line

        lastChar = line[line.length - 1]
        valid = if ending == 'windows'
            lastChar == '\r'
        else if ending == 'unix'
            lastChar != '\r'
        else
            throw new Error("unknown line ending type: #{ending}")
        if not valid
            return {context:"Expected #{ending}"}
        else
            return null
