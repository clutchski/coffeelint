
module.exports = class NoUnnecessaryDoubleQuotes

    rule:
        name: 'no_unnecessary_double_quotes'
        level: 'ignore'
        message: 'Unnecessary double quotes are forbidden'
        description: '''
            This rule prohibits double quotes unless string interpolation is
            used or the string contains single quotes.
            <pre>
            <code># Double quotes are discouraged:
            foo = "bar"

            # Unless string interpolation is used:
            foo = "#{bar}baz"

            # Or they prevent cumbersome escaping:
            foo = "I'm just following the 'rules'"
            </code>
            </pre>
            Double quotes are permitted by default.
            '''
    constructor: ->
        @regexps = []
        @isInterpolation = false

    tokens: ['STRING', 'STRING_START', 'STRING_END']

    lintToken: (token, tokenApi) ->
        [type, tokenValue] = token

        if type in ['STRING_START', 'STRING_END']
            return @trackParens arguments...

        stringValue = tokenValue.match(/^\"(.*)\"$/)

        return false unless stringValue # no double quotes, all OK

        hasLegalConstructs = @isInterpolation or @hasSingleQuote(tokenValue)
        return not hasLegalConstructs

    trackParens: (token, tokenApi) ->
        if token[0] is 'STRING_START'
            @isInterpolation = true
        else if token[0] is 'STRING_END'
            @isInterpolation = false
        # We're not linting, just tracking interpolations.
        null

    hasSingleQuote: (tokenValue) ->
        return tokenValue.indexOf("'") isnt -1
