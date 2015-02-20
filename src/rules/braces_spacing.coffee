module.exports = class BracesSpacing

    rule:
        name: 'braces_spacing'
        level: 'ignore'
        spaces: 0
        message: 'Curly braces must have the proper spacing'
        description: '''
            This rule checks to see that there is the proper spacing inside
            curly braces. The spacing amount is specified by "spaces".

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

    lintToken: (token, tokenApi) ->
        return null if token.generated

        [firstToken, secondToken] = if token[0] is '{'
            [token, @findNearestToken(token, tokenApi, 1)]
        else
            [@findNearestToken(token, tokenApi, -1), token]

        return null unless @tokensOnSameLine firstToken, secondToken

        expected = tokenApi.config[@rule.name].spaces
        actual = @distanceBetweenTokens firstToken, secondToken

        if actual is expected
            null
        else
            msg = "There should be #{expected} space"
            msg += 's' unless expected is 1
            msg += " inside \"#{token[0]}\""
            context: msg
