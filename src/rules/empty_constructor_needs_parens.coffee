
module.exports = class EmptyConstructorNeedsParens

    rule:
        name: 'empty_constructor_needs_parens'
        level: 'ignore'
        message: 'Invoking a constructor without parens and without arguments'
        description:
            "Requires constructors with no parameters to include the parens"

    tokens: [ 'UNARY' ]

    # Return an error if the given indentation token is not correct.
    lintToken: (token, tokenApi) ->
        if token[1] is 'new'
            # Find the last chained identifier, e.g. Bar in new foo.bar.Bar().
            identifierIndex = 1
            loop
                expectedIdentifier = tokenApi.peek(identifierIndex)
                expectedCallStart  = tokenApi.peek(identifierIndex + 1)
                if expectedIdentifier?[0] is 'IDENTIFIER'
                    if expectedCallStart?[0] is '.'
                        identifierIndex += 2
                        continue
                break

            # The callStart is generated if your parameters are all on the same
            # line with implicit parens, and if your parameters start on the
            # next line, but is missing if there are no params and no parens.
            if expectedIdentifier?[0] is 'IDENTIFIER' and expectedCallStart?
                return @handleExpectedCallStart expectedCallStart

    handleExpectedCallStart: (expectedCallStart) ->
        if expectedCallStart[0] isnt 'CALL_START'
            return true
