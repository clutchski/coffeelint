
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

    tokens: ['INDENT', "[", "]", "."]

    constructor: ->
        @arrayTokens = []   # A stack tracking the array token pairs.

    # Return an error if the given indentation token is not correct.
    lintToken: (token, tokenApi) ->
        [type, numIndents, { first_line: lineNumber }] = token

        lines = tokenApi.lines
        lineNumber = tokenApi.lineNumber
        currentLine = lines[lineNumber]
        expected = tokenApi.config[@rule.name].value

        # See: 'Indented chained invocations with bad indents'
        # This actually checks the chained call to see if its properly indented
        if type is '.'
            # Keep this if statement separately, since we still need to let
            # the linting pass if the '.' token is not at the beginning of
            # the line
            if currentLine.match(/\S/i)[0] is '.'
                lastCheck = 1
                callStart = 1
                prevNum = 1

                # Traverse up the token list until we see a CALL_START token.
                # Don't scan above this line
                while (tokenApi.peek(-callStart) and tokenApi.peek(-callStart)[0] isnt 'CALL_START')
                    { first_line: lastCheck } = tokenApi.peek(-callStart)[2]
                    callStart += 1

                # Keep going back until we are not at a comment or a blank line
                # and set a new "previousLine"
                while (lineNumber - prevNum > lastCheck) and not /^\s*\./.test(lines[lineNumber - prevNum])
                    prevNum += 1

                checkNum = lineNumber - prevNum
                if checkNum >= 0
                    prevLine = lines[checkNum]

                    # If this is just a one-chain function, or the "corrected"
                    # previous line begins with a '.', check for correct
                    # indentation
                    if prevLine.match(/\S/i)[0] is '.' or checkNum is lastCheck
                        currentSpaces = currentLine.match(/\S/i)?.index
                        prevSpaces = prevLine.match(/\S/i)?.index
                        numIndents = currentSpaces - prevSpaces

                        # If both prev and current lines have uneven spacing,
                        # assume the current line could be lined by default
                        # indent spacing, and set numIndents to current
                        # number of spaces
                        if prevSpaces % expected isnt 0 and currentSpaces % expected isnt 0
                            numIndents = currentSpaces

                        if numIndents % expected isnt 0
                            return { context: "Expected #{expected} got #{numIndents}" }
            return undefined

        if type in ["[", "]"]
            @lintArray(token)
            return undefined

        return null if token.generated?

        # HACK: CoffeeScript's lexer insert indentation in string
        # interpolations that start with spaces e.g. "#{ 123 }"
        # so ignore such cases. Are there other times an indentation
        # could possibly follow a '+'?
        previous = tokenApi.peek(-2)
        isInterpIndent = previous and previous[0] is '+'

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
            prevNum = 1

            # Keep going back until we are not at a comment or a blank line
            # and set a new "previousLine"
            prevNum += 1 while (/^\s*(#|$)/.test(lines[lineNumber - prevNum]))
            previousLine = lines[lineNumber - prevNum]

            previousIndentation = previousLine.match(/\S/).index

            # Original issue was #4, Updated again with #88 and discovered why
            # this was happening in #128. There is a lot of discussion on the
            # GitHub repo so please read those.

            # Basic summary: CoffeeScript sucks chained calls to the previous
            # line, leaving you with an indent one size bigger than desired.

            # NOTE: Adding this line moved the cyclomatic complexity over the
            # limit, I'm not sure why
            numIndents = currentLine.match(/\S/).index
            numIndents -= previousIndentation

        # Now check the indentation.
        if not ignoreIndent and numIndents isnt expected
            return { context: "Expected #{expected} got #{numIndents}" }

    # Return true if the current token is inside of an array.
    inArray : () ->
        return @arrayTokens.length > 0

    # Lint the given array token.
    lintArray : (token) ->
        # Track the array token pairs
        if token[0] is '['
            @arrayTokens.push(token)
        else if token[0] is ']'
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

        # What we're going to do is find all tokens with the newLine property
        # and then see if that token is an accessor ('.') or if its next non-
        # generated token is a '.'.

        # Grab all tokens with newLine properties
        newLineTokens = (j for token, j in tokens[..i] when token.newLine?)

        # Try to see if next ungenerated token after a token with newLine
        # property is an '.' token
        for l in newLineTokens
            ll = 1
            ll += 1 while tokens[l + ll].generated?
            return true if tokens[l + ll][0] is '.'

        return false
