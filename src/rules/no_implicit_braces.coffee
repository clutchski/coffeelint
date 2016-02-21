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

    tokens: ['{', 'OUTDENT', 'CLASS', 'IDENTIFIER', 'EXTENDS']

    constructor: ->
        @isClass = false
        @className = ''

    lintToken: (token, tokenApi) ->
        [type, val, lineNum] = token
        if type in ['OUTDENT', 'CLASS']
            return @trackClass arguments...

        # reset "className" if class uses EXTENDS keyword
        if type is 'EXTENDS'
            @className = ''
            return

        # If we're looking at an IDENTIFIER, and we're in a class, and we've not
        # set a className (or the previous non-identifier was 'EXTENDS', set the
        # current identifier as the class name)
        if type is 'IDENTIFIER' and @isClass and @className is ''
            # Backtrack to get the full classname
            c = 0
            while tokenApi.peek(c)[0] in ['IDENTIFIER', '.']
                @className += tokenApi.peek(c)[1]
                c++

        if token.generated and type is '{'
            # If strict mode is set to false it allows implicit braces when the
            # object is declared over multiple lines.
            unless tokenApi.config[@rule.name].strict
                [prevToken] = tokenApi.peek(-1)
                if prevToken in ['INDENT', 'TERMINATOR']
                    return

            if @isClass
                # The way CoffeeScript generates tokens for classes
                # is a bit weird. It generates '{' tokens around instance
                # methods (also known as the prototypes of an Object).

                [prevToken] = tokenApi.peek(-1)
                # If there is a TERMINATOR token right before the '{' token
                if prevToken is 'TERMINATOR'
                    return

                peekIdent = ''
                c = -2
                # Go back until you grab all the tokens with IDENTIFIER or '.'
                while ([_type, _val] = tokenApi.peek(c))
                    break if _type not in ['IDENTIFIER', '.']
                    peekIdent = _val + peekIdent
                    c--

                if peekIdent is @className
                    return

            return true

    trackClass: (token, tokenApi) ->
        [[n0, ..., ln], [n1, ...]] = [token, tokenApi.peek()]

        if n0 is 'OUTDENT' and n1 is 'TERMINATOR'
            @isClass = false
        if n0 is 'CLASS'
            @isClass = true
            @className = ''
        return null
