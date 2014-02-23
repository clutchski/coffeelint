
module.exports = class SpaceOperators

    rule:
        name: 'space_operators'
        level : 'ignore'
        message : 'Operators must be spaced properly'
        description: "This rule enforces that operators have space around them."

    tokens: [ "+", "-", "=", "**", "MATH", "COMPARE", "LOGIC",
        "COMPOUND_ASSIGN", "(", ")", "CALL_START", "CALL_END" ]

    constructor: ->
        @callTokens = []    # A stack tracking the call token pairs.
        @parenTokens = []   # A stack tracking the parens token pairs.

    lintToken : ([type], tokenApi) ->

        # These just keep track of state
        if type in [ "CALL_START", "CALL_END" ]
            @lintCall arguments...
            return undefined
        if type in [ "(", ")" ]
            @lintParens arguments...
            return undefined


        # These may return errors
        if type in [ "+", "-" ]
            @lintPlus arguments...
        else
            @lintMath arguments...

    lintPlus: (token, tokenApi) ->
        # We can't check this inside of interpolations right now, because the
        # plusses used for the string type co-ercion are marked not spaced.
        if @isInInterpolation() or @isInExtendedRegex()
            return null

        p = tokenApi.peek(-1)
        unaries = ['TERMINATOR', '(', '=', '-', '+', ',', 'CALL_START',
                    'INDEX_START', '..', '...', 'COMPARE', 'IF',
                    'THROW', 'LOGIC', 'POST_IF', ':', '[', 'INDENT',
                    'COMPOUND_ASSIGN', 'RETURN', 'MATH', 'BY', 'LEADING_WHEN']
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

    isInExtendedRegex : () ->
        for t in @callTokens
            return true if t.isRegex
        return false

    lintCall : (token, tokenApi) ->
        if token[0] == 'CALL_START'
            p = tokenApi.peek(-1)
            # Track regex calls, to know (approximately) if we're in an
            # extended regex.
            token.isRegex = p and p[0] == 'IDENTIFIER' and p[1] == 'RegExp'
            @callTokens.push(token)
        else
            @callTokens.pop()
        return null

    isInInterpolation : () ->
        for t in @parenTokens
            return true if t.isInterpolation
        return false

    lintParens : (token, tokenApi) ->
        if token[0] == '('
            p1 = tokenApi.peek(-1)
            n1 = tokenApi.peek(1)
            n2 = tokenApi.peek(2)
            # String interpolations start with '' + so start the type co-ercion,
            # so track if we're inside of one. This is most definitely not
            # 100% true but what else can we do?
            i = n1 and n2 and n1[0] == 'STRING' and n2[0] == '+'
            token.isInterpolation = i
            @parenTokens.push(token)
        else
            @parenTokens.pop()
        # We're not linting, just tracking interpolations.
        null
