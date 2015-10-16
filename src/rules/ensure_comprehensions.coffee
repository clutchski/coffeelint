module.exports = class EnsureComprehensions

    rule:
        name: 'ensure_comprehensions'
        level: 'warn'
        message: 'Comprehensions must have parentheses around them'
        description: '''
            This rule makes sure that parentheses are around comprehensions.
            '''

    tokens: ['FOR']

    forBlock: false

    lintToken: (token, tokenApi) ->
        # Rules
        # Ignore if normal for-loop with a block
        # If LHS of operation contains either the key or value variable of
        #     the loop, assume that it is not a comprehension.

        # Find all identifiers (including lhs values and parts of for loop)
        idents = @findIdents(tokenApi)

        # if it looks like a for block, don't bother checking
        if @forBlock
            @forBlock = false
            return

        peeker = -1
        atEqual = false
        numCallEnds = 0
        numCallStarts = 0
        numParenStarts = 0
        numParenEnds = 0
        prevIdents = []

        while (prevToken = tokenApi.peek(peeker))

            numCallEnds++ if prevToken[0] is 'CALL_END'
            numCallStarts++ if prevToken[0] is 'CALL_START'

            numParenStarts++ if prevToken[0] is '('
            numParenEnds++ if prevToken[0] is ')'

            if prevToken[0] is 'IDENTIFIER'
                if not atEqual
                    prevIdents.push prevToken[1]
                else if prevToken[1] in idents
                    return

            if prevToken[0] in ['(', '->', 'TERMINATOR'] or prevToken.newLine?
                break

            if prevToken[0] is '=' and numParenEnds is numParenStarts
                atEqual = true

            peeker--

        # If we hit a terminal node (TERMINATOR token or w/ property newLine)
        # or if we hit the top of the file and we've seen an '=' sign without
        # any identifiers that are part of the for-loop, and there is an equal
        # amount of CALL_START/CALL_END tokens. An unequal number means the list
        # comprehension is inside of a function call
        if atEqual and numCallStarts is numCallEnds
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

        # now search ahead to see if this becomes a FOR block
        while (nextToken = tokenApi.peek(peeker))
            if nextToken[0] is 'TERMINATOR'
                break
            if nextToken[0] is 'INDENT'
                @forBlock = true
                break
            peeker++

        return idents
