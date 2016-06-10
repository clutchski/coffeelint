module.exports = class EmptyConstructorNeedsParens

    rule:
        name: 'empty_constructor_needs_parens'
        level: 'ignore'
        message: 'Invoking a constructor without parens and without arguments'
        description: '''
            Requires constructors with no parameters to include the parens
            '''

    tokens: ['UNARY']

    # Return an error if the given indentation token is not correct.
    lintToken: (token, tokenApi) ->
        if token[1] is 'new'
            peek = tokenApi.peek.bind(tokenApi)
            # Find the last chained identifier, e.g. Bar in new foo.bar.Bar().
            identIndex = 1
            loop
                isIdent = peek(identIndex)?[0] in ['IDENTIFIER', 'PROPERTY']
                nextToken = peek(identIndex + 1)
                if isIdent
                    if nextToken?[0] is '.'
                        # skip the dot and start with the next token
                        identIndex += 2
                        continue
                    if nextToken?[0] is 'INDEX_START'
                        while peek(identIndex)?[0] isnt 'INDEX_END'
                            identIndex++
                        continue

                break

            # The callStart is generated if your parameters are all on the same
            # line with implicit parens, and if your parameters start on the
            # next line, but is missing if there are no params and no parens.
            if isIdent and nextToken?
                return @handleExpectedCallStart(nextToken)

    handleExpectedCallStart: (isCallStart) ->
        if isCallStart[0] isnt 'CALL_START'
            return true
