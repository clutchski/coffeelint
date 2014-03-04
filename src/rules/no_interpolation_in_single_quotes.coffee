

module.exports = class NoInterpolationInSingleQuotes

    rule:
        name: 'no_interpolation_in_single_quotes'
        level: 'ignore'
        message: 'Interpolation in single quoted strings is forbidden'
        description: '''
            This rule prohibits string interpolation in a single quoted string.
            <pre>
            <code># String interpolation in single quotes is not allowed:
            foo = '#{bar}'

            # Double quotes is OK of course
            foo = "#{bar}"
            </code>
            </pre>
            String interpolation in single quoted strings is permitted by 
            default.
            '''

    tokens: [ 'STRING' ]

    lintToken : (token, tokenApi) ->
        tokenValue = token[1]

        hasInterpolation = tokenValue.match(/#\{[^}]+\}/)
        return hasInterpolation
