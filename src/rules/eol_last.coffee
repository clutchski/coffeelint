
module.exports = class EOLLast

    rule:
        name: 'eol_last'
        level : 'ignore'
        message : 'File does not end with a single newline'
        description: "Checks that the file ends with a single newline"

    lintLine: (line, lineApi) ->
        return null unless lineApi.isLastLine()

        return true if line.length
