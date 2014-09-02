module.exports = class EnsureComprehensions

    rule:
        name: 'ensure_comprehensions'
        level: 'warn'
        message: 'Comprehensions must have parentheses around them'
        description:
            'This rule makes sure that parentheses are around comprehensions.'

    tokens: ['FOR']

    lintToken: (token, tokenApi) ->
        # Rules
        # Ignore if normal for-loop with a block
        # If LHS of operation contains either the key or value variable of
        #     the loop, assume that it is not a comprehension.

        idents = @findIdents(tokenApi)

        peeker = -1
        atEqual = false
        prevIdents = []
        while (prevToken = tokenApi.peek(peeker))
            if prevToken[0] is 'IDENTIFIER'
                if not atEqual
                    prevIdents.push prevToken[1]
                else if prevToken[1] in idents
                    return

            if prevToken[0] in ['(', '->', 'TERMINATOR'] or prevToken.newLine?
                break
            if prevToken[0] is '='
                atEqual = true
            peeker--

        # If we hit a terminal node (TERMINATOR token or w/ property newLine)
        # or if we hit the top of the file and we've seen an '=' sign without
        # any identifiers that are part of the for-loop, or
        if atEqual and prevIdents.length > 0
            return { context: '' }

    findIdents: (tokenApi) ->
        peeker = 1
        idents = []

        while (nextToken = tokenApi.peek(peeker))
            if nextToken[0] is 'IDENTIFIER'
                idents.push(nextToken[1])
            if nextToken[0] in ['FORIN', 'FOROF']
                break
            peeker++
        return idents
