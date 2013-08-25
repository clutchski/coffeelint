
module.exports = class SpaceOperators

    rule:
        name: 'space_operators'
        level : 'ignore'
        message : 'Operators must be spaced properly'
        description: "This rule enforces that operators have space around them."



    tokens: [ "+", "-", "=", "MATH", "COMPARE", "LOGIC", "COMPOUND_ASSIGN" ]

    lintToken : ([type], tokenApi) ->
        if type in [ "+", "-" ]
            @lintPlus arguments...
        else
            @lintMath arguments...

    lintPlus: (token, tokenApi) ->
        # We can't check this inside of interpolations right now, because the
        # plusses used for the string type co-ercion are marked not spaced.
        if tokenApi.isInInterpolation() or tokenApi.isInExtendedRegex()
            return null

        p = tokenApi.peek(-1)
        unaries = ['TERMINATOR', '(', '=', '-', '+', ',', 'CALL_START',
                    'INDEX_START', '..', '...', 'COMPARE', 'IF',
                    'THROW', 'LOGIC', 'POST_IF', ':', '[', 'INDENT',
                    'COMPOUND_ASSIGN', 'RETURN', 'MATH', 'BY']
        isUnary = if not p then false else p[0] in unaries
        if (isUnary and token.spaced) or
                    (not isUnary and not token.spaced and not token.newLine)
            return {context: token[1]}
        else
            null

    lintMath: (token, tokenApi) ->
        if not token.spaced and not token.newLine
            return {context: token[1]}
        else
            null

