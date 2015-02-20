
module.exports = class NoImplicitBraces

    rule:
        name: 'no_implicit_braces'
        level: 'ignore'
        message: 'Implicit braces are forbidden'
        strict: true
        description: '''
            This rule prohibits implicit braces when declaring object literals.
            Implicit braces can make code more difficult to understand,
            especially when used in combination with optional parenthesis.
            <pre>
            <code># Do you find this code ambiguous? Is it a
            # function call with three arguments or four?
            myFunction a, b, 1:2, 3:4

            # While the same code written in a more
            # explicit manner has no ambiguity.
            myFunction(a, b, {1:2, 3:4})
            </code>
            </pre>
            Implicit braces are permitted by default, since their use is
            idiomatic CoffeeScript.
        '''

    tokens: ['{', 'OUTDENT', 'CLASS']

    constructor: ->
        @isClass = false
        @classBrace = false

    lintToken: (token, tokenApi) ->
        [type, val, lineNum] = token

        if type is 'OUTDENT' or type is 'CLASS'
            return @trackClass arguments...

        if token.generated
            # If we're inside a class but have not yet seen a brace,
            # allow this generated brace THIS ONE TIME
            if @classBrace
                @classBrace = false
                return

            # If strict mode is turned off it allows implicit braces when the
            # object is declared over multiple lines.
            unless tokenApi.config[@rule.name].strict
                [previousToken] = tokenApi.peek(-1)
                if previousToken is 'INDENT'
                    return
            return true

    trackClass: (token, tokenApi) ->
        [[n0, ..., ln], [n1, ...]] = [token, tokenApi.peek()]

        if n0 is 'OUTDENT' and n1 is 'TERMINATOR'
            @isClass = false
            @classBrace = false
        if n0 is 'CLASS'
            @isClass = true
            @classBrace = true
        return null
