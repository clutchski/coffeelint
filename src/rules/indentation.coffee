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

    tokens: ['INDENT', '[', ']', '.']

    keywords: [
      '->', '=>', '@', 'CATCH', 'CLASS', 'ELSE', 'FINALLY', 'FOR',
      'FORIN', 'FOROF', 'IDENTIFIER', 'IF', 'LEADING_WHEN', 'LOOP',
      'RETURN', 'SWITCH', 'THROW', 'TRY', 'UNTIL', 'WHEN', 'WHILE',
      'YIELD'
    ]

    constructor: ->
        @arrayTokens = []   # A stack tracking the array token pairs.

    # Return an error if the given indentation token is not correct.
    lintToken: (token, tokenApi) ->
        [type, numIndents, { first_line: lineNumber }] = token
        { lines, lineNumber } = tokenApi

        expected = tokenApi.config[@rule.name].value

        # See: 'Indented chained invocations with bad indents'
        # This actually checks the chained call to see if its properly indented
        if type is '.'
            # Keep this if statement separately, since we still need to let
            # the linting pass if the '.' token is not at the beginning of
            # the line
            currentLine = lines[lineNumber]
            if currentLine.match(/\S/)?[0] is '.'
                return @handleChain(tokenApi, expected)
            return undefined

        if type in ['[', ']']
            @lintArray(token)
            return undefined

        return null if token.generated? or token.explicit?

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
        ignoreIndent = isArrayIndent or isMultiline

        # Correct CoffeeScript's incorrect INDENT token value when functions
        # get chained. See https://github.com/jashkenas/coffeescript/issues/3137
        # Also see CoffeeLint Issues: #4, #88, #128, and many more.
        numIndents = @getCorrectIndent(tokenApi)

        # Now check the indentation.
        if not ignoreIndent and not (expected in numIndents)
            return { context: "Expected #{expected} got #{numIndents[0]}" }

    # Return true if the current token is inside of an array.
    inArray: () ->
        return @arrayTokens.length > 0

    # Lint the given array token.
    lintArray: (token) ->
        # Track the array token pairs
        if token[0] is '['
            @arrayTokens.push(token)
        else if token[0] is ']'
            @arrayTokens.pop()
        # Return null, since we're not really linting
        # anything here.
        null

    handleChain: (tokenApi, expected) ->
        lastCheck = 1
        callStart = 1
        prevNum = 1

        { lineNumber, lines } = tokenApi
        currentLine = lines[lineNumber]

        # Traverse up the token list until we see a CALL_START token.
        # Don't scan above this line
        findCallStart = tokenApi.peek(-callStart)
        while (findCallStart and findCallStart[0] isnt 'TERMINATOR')
            { first_line: lastCheck } = findCallStart[2]

            callStart += 1
            findCallStart = tokenApi.peek(-callStart)

        # Keep going back until we are not at a comment or a blank lines
        # and set a new "previousLine"
        while (lineNumber - prevNum > lastCheck) and
                not /^\s*\./.test(lines[lineNumber - prevNum])
            prevNum += 1

        checkNum = lineNumber - prevNum
        if checkNum >= 0
            prevLine = lines[checkNum]

            # If this is just a one-chain function, or the "corrected"
            # previous line begins with a '.', check for correct
            # indentation
            if prevLine.match(/\S/)[0] is '.' or checkNum is lastCheck
                currentSpaces = currentLine.match(/\S/)?.index
                prevSpaces = prevLine.match(/\S/)?.index
                numIndents = currentSpaces - prevSpaces

                # If both prev and current lines have uneven spacing,
                # assume the current line could be lined by default
                # indent spacing, and set numIndents to current
                # number of spaces
                prevIsIndent = prevSpaces % expected isnt 0
                currIsIndent = currentSpaces % expected isnt 0

                if prevIsIndent and currIsIndent
                    numIndents = currentSpaces

                if numIndents % expected isnt 0
                    return { context: "Expected #{expected} got #{numIndents}" }

    grabLineTokens: (tokenApi, lineNumber, all = false) ->
        { tokensByLine } = tokenApi
        lineNumber-- until tokensByLine[lineNumber]? or lineNumber is 0

        if all
            (tok for tok in tokensByLine[lineNumber])
        else
            (tok for tok in tokensByLine[lineNumber] when not
                tok.generated? and tok[0] isnt 'OUTDENT')

    # Returns a corrected INDENT value if the current line is part of
    # a chained call. Otherwise returns original INDENT value.
    getCorrectIndent: (tokenApi) ->
        { lineNumber, lines, tokens } = tokenApi

        curIndent = lines[lineNumber].match(/\S/)?.index

        prevNum = 1
        prevNum += 1 while (/^\s*(#|$)/.test(lines[lineNumber - prevNum]))

        prevTokens = @grabLineTokens tokenApi, lineNumber - prevNum

        if prevTokens[0]?[0] is 'INDENT'
            # Pass both the INDENT value and the location of the first token
            # after the INDENT because sometimes CoffeeScript doesn't return
            # the correct INDENT if there is something like an if/else
            # inside an if/else inside of a -> function definition: e.g.
            #
            # ->
            #   r = if a
            #     if b
            #       2
            #     else
            #       3
            #   else
            #     4
            #
            # will error without: curIndent - prevTokens[1]?[2].first_column

            return [curIndent - prevTokens[1]?[2].first_column,
                curIndent - prevTokens[0][1]]
        else
            prevIndent = prevTokens[0]?[2].first_column
            # This is a scan to handle extra indentation from if/else
            # statements to make them look nicer: e.g.
            #
            # r = if a
            #   true
            # else
            #   false
            #
            # is valid.
            #
            # r = if a
            #       true
            #     else
            #       false
            #
            # is also valid.
            for _, j in prevTokens when prevTokens[j][0] is '=' and
                    prevTokens[j + 1]?[0] is 'IF'
                skipAssign = curIndent - prevTokens[j + 1][2].first_column
                ret = curIndent - prevIndent
                return [ret] if skipAssign < 0
                return [skipAssign, ret]

            # This happens when there is an extra indent to maintain long
            # conditional statements (IF/UNLESS): e.g.
            #
            # ->
            #   if a is c and
            #     (false or
            #       long.expression.that.necessitates(linebreak))
            #     @foo()
            #
            # is valid (note that there an only an extra indent in the last
            # statement is required and not the line above it
            #
            # ->
            #   if a is c and
            #       (false or
            #       long.expression.that.necessitates(linebreak))
            #     @foo()
            # is also OK.
            while prevIndent > curIndent
                tryLine = lineNumber - prevNum
                prevTokens = @grabLineTokens tokenApi, tryLine, true

                # This is to handle weird object/string indentation.
                # See: 'Handle edge-case weirdness with strings in objects'
                #   test case in test_indentation.coffee or in the file,
                #   test_no_empty_functions.coffee, which is why/how I
                #   caught this.
                if prevTokens[0]?[0] is 'INDENT'
                    prevIndent = prevTokens[0][1]
                    prevTokens = prevTokens[1..]

                t = 0
                # keep looping prevTokens until we find a token in @keywords
                # or we just run out of tokens in prevTokens
                until not prevTokens[t]? or prevTokens[t][0] in @keywords
                    t++

                # slice off everything before 't'
                prevTokens = prevTokens[t..]
                prevNum++

                # if there isn't a valid token, restart the while loop
                continue unless prevTokens[0]?

                # set new "prevIndent"
                prevIndent = prevTokens[0]?[2].first_column

        return [curIndent - prevIndent]
