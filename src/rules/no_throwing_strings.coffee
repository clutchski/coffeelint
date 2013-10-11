
module.exports = class NoThrowingStrings

    rule:
        name: 'no_throwing_strings'
        level : 'error'
        message : 'Throwing strings is forbidden'
        description: """
            This rule forbids throwing string literals or interpolations. While
            JavaScript (and CoffeeScript by extension) allow any expression to
            be thrown, it is best to only throw <a
            href="https://developer.mozilla.org
            /en/JavaScript/Reference/Global_Objects/Error"> Error</a> objects,
            because they contain valuable debugging information like the stack
            trace. Because of JavaScript's dynamic nature, CoffeeLint cannot
            ensure you are always throwing instances of <tt>Error</tt>. It will
            only catch the simple but real case of throwing literal strings.
            <pre>
            <code># CoffeeLint will catch this:
            throw "i made a boo boo"

            # ... but not this:
            throw getSomeString()
            </code>
            </pre>
            This rule is enabled by default.
            """

    tokens: [ "THROW" ]

    lintToken : (token, tokenApi) ->
        [n1, n2] = [tokenApi.peek(), tokenApi.peek(2)]
        # Catch literals and string interpolations, which are wrapped in
        # parens.
        nextIsString = n1[0] == 'STRING' or (n1[0] == '(' and n2[0] == 'STRING')
        return nextIsString
