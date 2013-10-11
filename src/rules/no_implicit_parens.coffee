
module.exports = class NoImplicitParens

    rule:
        name: 'no_implicit_parens'
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


    tokens: [ "CALL_START" ]

    lintToken : (token, tokenApi) ->
        return token.generated

