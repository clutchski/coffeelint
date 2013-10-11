
module.exports = class Indentation

    rule:
        name: 'indentation'
        value : 2
        level : 'error'
        message : 'Line contains inconsistent indentation'
        description: """
            This rule imposes a standard number of spaces to be used for
            indentation. Since whitespace is significant in CoffeeScript, it's
            critical that a project chooses a standard indentation format and
            stays consistent. Other roads lead to darkness. <pre> <code>#
            Enabling this option will prevent this ugly
            # but otherwise valid CoffeeScript.
            twoSpaces = () ->
              fourSpaces = () ->
                  eightSpaces = () ->
                        'this is valid CoffeeScript'

            </code>
            </pre>
            Two space indentation is enabled by default.
            """


    tokens: [ 'INDENT', "[", "]" ]

    constructor: ->
        @arrayTokens = []   # A stack tracking the array token pairs.

    # Return an error if the given indentation token is not correct.
    lintToken: (token, tokenApi) ->
        [type, numIndents, lineNumber] = token

        if type in [ "[", "]" ]
            @lintArray(token)
            return undefined

        return null if token.generated?

        # HACK: CoffeeScript's lexer insert indentation in string
        # interpolations that start with spaces e.g. "#{ 123 }"
        # so ignore such cases. Are there other times an indentation
        # could possibly follow a '+'?
        previous = tokenApi.peek(-2)
        isInterpIndent = previous and previous[0] == '+'

        # Ignore the indentation inside of an array, so that
        # we can allow things like:
        #   x = ["foo",
        #             "bar"]
        previous = tokenApi.peek(-1)
        isArrayIndent = @inArray() and previous?.newLine

        # Ignore indents used to for formatting on multi-line expressions, so
        # we can allow things like:
        #   a = b =
        #     c = d
        previousSymbol = tokenApi.peek(-1)?[0]
        isMultiline = previousSymbol in ['=', ',']

        # Summarize the indentation conditions we'd like to ignore
        ignoreIndent = isInterpIndent or isArrayIndent or isMultiline

        # Compensate for indentation in function invocations that span multiple
        # lines, which can be ignored.
        if @isChainedCall tokenApi
            { lines, lineNumber } = tokenApi
            currentLine = lines[lineNumber]
            prevNum = 1

            # keep going back until we are not at a comment or a blank line
            prevNum += 1 while (/^\s*(#|$)/.test(lines[lineNumber - prevNum]))
            previousLine = lines[lineNumber - prevNum]

            previousIndentation = previousLine.match(/^(\s*)/)[1].length
            # I don't know why, but when inside a function, you make a chained
            # call and define an inline callback as a parameter, the body of
            # that callback gets the indentation reported higher than it really
            # is. See issue #88
            # NOTE: Adding this line moved the cyclomatic complexity over the
            # limit, I'm not sure why
            numIndents = currentLine.match(/^(\s*)/)[1].length
            numIndents -= previousIndentation


        # Now check the indentation.
        expected = tokenApi.config[@rule.name].value
        if not ignoreIndent and numIndents != expected
            return {
                context: "Expected #{expected} got #{numIndents}"
            }
    # Return true if the current token is inside of an array.
    inArray : () ->
        return @arrayTokens.length > 0

    # Lint the given array token.
    lintArray : (token) ->
        # Track the array token pairs
        if token[0] == '['
            @arrayTokens.push(token)
        else if token[0] == ']'
            @arrayTokens.pop()
        # Return null, since we're not really linting
        # anything here.
        null

    # Return true if the current token is part of a property access
    # that is split across lines, for example:
    #   $('body')
    #       .addClass('foo')
    #       .removeClass('bar')
    isChainedCall: (tokenApi) ->
        { tokens, i } = tokenApi
        # Get the index of the second most recent new line.
        lines = (i for token, i in tokens[..i] when token.newLine?)

        lastNewLineIndex = if lines then lines[lines.length - 2] else null

        # Bail out if there is no such token.
        return false if not lastNewLineIndex?

        # Otherwise, figure out if that token or the next is an attribute
        # look-up.
        tokens = [tokens[lastNewLineIndex], tokens[lastNewLineIndex + 1]]

        return !!(t for t in tokens when t and t[0] == '.').length

