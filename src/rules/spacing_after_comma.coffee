
module.exports = class RuleProcessor
    rule:
        name: 'spacing_after_comma'
        description: 'This rule requires a space after commas.'
        level: 'ignore'
        message: 'Spaces are required after commas'

    tokens: [',', 'REGEX_START', 'REGEX_END']

    constructor: ->
        @inRegex = false

    lintToken: (token, tokenApi) ->
        [ type ] = token

        if type is 'REGEX_START'
            @inRegex = true
            return
        if type is 'REGEX_END'
            @inRegex = false
            return

        unless token.spaced or token.newLine or token.generated or
                @isRegexFlag(token, tokenApi)
            {context : token[1]}

    # When generating a regex (///${whatever}///i) CoffeeScript generates tokens
    # for RegEx(whatever, "i") but doesn't bother to mark that comma as
    # generated or spaced. Looking 3 tokens ahead skips the STRING and CALL_END
    isRegexFlag: (token, tokenApi) ->
        return false unless @inRegex

        maybeEnd = tokenApi.peek(3)
        return maybeEnd?[0] is 'REGEX_END'
