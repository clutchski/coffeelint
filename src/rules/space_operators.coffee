module.exports = class SpaceOperators

    rule:
        name: 'space_operators'
        level: 'ignore'
        message: 'Operators must be spaced properly'
        description: '''
            This rule enforces that operators have spaces around them.
            '''

    tokens: ['+', '-', '=', '**', 'MATH', 'COMPARE',
        '&', '^', '|', '&&', '||', 'COMPOUND_ASSIGN',
        'STRING_START', 'STRING_END', 'CALL_START', 'CALL_END'
    ]

    constructor: ->
        @callTokens = []    # A stack tracking the call token pairs.
        @parenTokens = []   # A stack tracking the parens token pairs.
        @interpolationLevel = 0

    lintToken: (token, tokenApi) ->
        [type, rest...] = token
        # These just keep track of state
        if type in ['CALL_START', 'CALL_END']
            @trackCall token, tokenApi
            return

        if type in ['STRING_START', 'STRING_END']
            return @trackParens token, tokenApi

        # These may return errors
        if type in ['+', '-']
            @lintPlus token, tokenApi
        else
            @lintMath token, tokenApi

    lintPlus: (token, tokenApi) ->
        # We can't check this inside of interpolations right now, because the
        # plusses used for the string type co-ercion are marked not spaced.
        if @isInInterpolation() or @isInExtendedRegex()
            return null

        p = tokenApi.peek(-1)

        unaries = ['TERMINATOR', '(', '=', '-', '+', ',', 'CALL_START',
                    'INDEX_START', '..', '...', 'COMPARE', 'IF', 'THROW',
                    '&', '^', '|', '&&', '||', 'POST_IF', ':', '[', 'INDENT',
                    'COMPOUND_ASSIGN', 'RETURN', 'MATH', 'BY', 'LEADING_WHEN']

        isUnary = if not p then false else p[0] in unaries
        notFirstToken = (p or token.spaced? or token.newLine)
        if notFirstToken and ((isUnary and token.spaced?) or
                (not isUnary and not token.newLine and
                (not token.spaced or (p and not p.spaced))))
            return { context: token[1] }
        else
            null

    lintMath: (token, tokenApi) ->
        p = tokenApi.peek(-1)
        if not token.newLine and (not token.spaced or (p and not p.spaced))
            return { context: token[1] }
        else
            null

    isInExtendedRegex: () ->
        for t in @callTokens
            return true if t.isRegex
        return false

    isInInterpolation: () ->
        @interpolationLevel > 0

    trackCall: (token, tokenApi) ->
        if token[0] is 'CALL_START'
            p = tokenApi.peek(-1)
            # Track regex calls, to know (approximately) if we're in an
            # extended regex.
            token.isRegex = p and p[0] is 'IDENTIFIER' and p[1] is 'RegExp'
            @callTokens.push(token)
        else
            @callTokens.pop()
        return null

    trackParens: (token, tokenApi) ->
        if token[0] is 'STRING_START'
            @interpolationLevel += 1
        else if token[0] is 'STRING_END'
            @interpolationLevel -= 1
        # We're not linting, just tracking interpolations.
        null
