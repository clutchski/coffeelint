module.exports = class BracesSpacing

    rule:
        name: 'braces_spacing'
        level: 'ignore'
        spaces: 0
        empty_object_spaces: 0
        message: 'Curly braces must have the proper spacing'
        description: '''
            This rule checks to see that there is the proper spacing inside
            curly braces. The spacing amount is specified by "spaces".
            The spacing amount for empty objects is specified by
            "empty_object_spaces".

            <pre><code>
            # Spaces is 0
            {a: b}     # Good
            {a: b }    # Bad
            { a: b}    # Bad
            { a: b }   # Bad

            # Spaces is 1
            {a: b}     # Bad
            {a: b }    # Bad
            { a: b}    # Bad
            { a: b }   # Good
            { a: b  }  # Bad
            {  a: b }  # Bad
            {  a: b  } # Bad

            # Empty Object Spaces is 0
            {}         # Good
            { }        # Bad

            # Empty Object Spaces is 1
            {}         # Bad
            { }        # Good
            </code></pre>

            This rule is disabled by default.
            '''

    tokens: ['{', '}']

    distanceBetweenTokens: (firstToken, secondToken) ->
        secondToken[2].first_column - firstToken[2].last_column - 1

    findNearestToken: (token, tokenApi, difference) ->
        totalDifference = 0
        while true
            totalDifference += difference
            nearestToken = tokenApi.peek(totalDifference)
            continue if nearestToken[0] is 'OUTDENT'
            return nearestToken

    tokensOnSameLine: (firstToken, secondToken) ->
        firstToken[2].first_line is secondToken[2].first_line

    getExpectedSpaces: (tokenApi, firstToken, secondToken) ->
        config = tokenApi.config[@rule.name]
        if firstToken[0] is '{' and secondToken[0] is '}'
            config.empty_object_spaces ? config.spaces
        else
            config.spaces

    lintToken: (token, tokenApi) ->
        return null if token.generated

        [firstToken, secondToken] = if token[0] is '{'
            [token, @findNearestToken(token, tokenApi, 1)]
        else
            [@findNearestToken(token, tokenApi, -1), token]

        return null unless @tokensOnSameLine firstToken, secondToken

        expected = @getExpectedSpaces tokenApi, firstToken, secondToken
        actual = @distanceBetweenTokens firstToken, secondToken

        if actual is expected
            null
        else
            msg = "There should be #{expected} space"
            msg += 's' unless expected is 1
            msg += " inside \"#{token[0]}\""
            context: msg
