
module.exports = class NoImplicitParens

    rule:
        name: 'no_implicit_parens'
        strict : true
        level : 'ignore'
        message : 'Implicit parens are forbidden'
        description: """
            This rule prohibits implicit parens on function calls.
            <pre>
            <code># Some folks don't like this style of coding.
            myFunction a, b, c

            # And would rather it always be written like this:
            myFunction(a, b, c)
            </code>
            </pre>
            Implicit parens are permitted by default, since their use is
            idiomatic CoffeeScript.
            """


    tokens: [ "CALL_END" ]

    lintToken : (token, tokenApi) ->
        if token.generated
            unless tokenApi.config[@rule.name].strict == false
                return true
            else
                # If strict mode is turned off it allows implicit parens when the
                # expression is spread over multiple lines.
                functionNesting = 1
                last_line = token[2].last_line
                i = -1
                loop
                    t = tokenApi.peek(i)
                    if t?[0] == 'CALL_END'
                        functionNesting += 1
                    if functionNesting == 1 and (not t? or t[0] == 'CALL_START')
                        return true
                    if t[2].first_line < last_line || t[0] == 'INDENT'
                        return null
                    if t?[0] == 'CALL_START'
                        functionNesting -= 1
                    i -= 1
