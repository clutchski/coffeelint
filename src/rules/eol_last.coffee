
module.exports = class EOLLast

    rule:
        name: 'eol_last'
        level : 'ignore'
        message : 'File does not end with a single newline'
        description: "Checks that the file ends with a single newline"

    lintLine: (line, lineApi) ->
        return null unless lineApi.isLastLine()

        lastLineIsNewline = line.length is 0

        nextToLastLineIsNewline = if lineApi.lineCount > 1
            lineApi.lines[lineApi.lineNumber - 1].length is 0
        else
            no

        return true unless lastLineIsNewline && !nextToLastLineIsNewline
