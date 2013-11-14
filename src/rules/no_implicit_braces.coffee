
module.exports = class NoImplicitBraces

    rule:
        name: 'no_implicit_braces'
        level : 'ignore'
        message : 'Implicit braces are forbidden'
        strict: true
        description: """
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
            """

    tokens: [ "{" ]

    lintToken: (token, tokenApi) ->
        if token.generated

            # If strict mode is turned off it allows implicit braces when the
            # object is declared over multiple lines.
            unless tokenApi.config[@rule.name].strict
                [ previousToken ] = tokenApi.peek(-1)
                if  previousToken is 'INDENT'
                    return

            @isPartOfClass(tokenApi)


    isPartOfClass: (tokenApi) ->
            # Peek back to the last line break. If there is a class
            # definition, ignore the generated brace.
            i = -1
            loop
                t = tokenApi.peek(i)
                if not t? or t[0] == 'TERMINATOR'
                    return true
                if t[0] == 'CLASS'
                    return null
                i -= 1
