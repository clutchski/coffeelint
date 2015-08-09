
module.exports = class SpaceOperators

    rule:
        name: 'space_operators'
        level : 'ignore'
        message : 'Operators must be spaced properly'
        description: """
            This rule enforces that operators have space around them.
            Optionally, you can set `default_parameters` to `false` to
            require no space around `=` when used to define default paramaters.
        """
        default_parameters: true

    tokens: ['+', '-', '=', '**', 'MATH', 'COMPARE', 'LOGIC', 'COMPOUND_ASSIGN',
        'STRING_START', 'STRING_END', 'CALL_START', 'CALL_END', 'PARAM_START'
        'PARAM_END']

    constructor: ->
        @callTokens = []    # A stack tracking the call token pairs.
        @parenTokens = []   # A stack tracking the parens token pairs.
        @interpolationLevel = 0
        @isParam = 0

    lintToken: ([type], tokenApi) ->
        # These just keep track of state
        if type in [ 'CALL_START', 'CALL_END' ]
            @trackCall arguments...
            return

        if type in [ 'PARAM_START', 'PARAM_END' ]
            @trackParams arguments...
            return

        if type in [ 'STRING_START', 'STRING_END' ]
            @trackParens arguments...
            return

        # These may return errors
        if type in [ '+', '-' ]
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
        if (isUnary and token.spaced?) or
                (not isUnary and not token.newLine and
                (not token.spaced or (p and not p.spaced)))
            return {context: token[1]}
        else
            null

    lintMath: (token, tokenApi) ->
        default_parameters = tokenApi.config[@rule.name].default_parameters
        p = tokenApi.peek(-1)
        if not default_parameters and @isParam > 0 and token[0] is '='
            if token.spaced or (p and p.spaced)
                return {context: token[1]}
            else
                return null
        else if not token.newLine and (not token.spaced or (p and not p.spaced))
            return {context: token[1]}
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

    trackParams: (token, tokenApi) ->
        if token[0] is 'PARAM_START'
            @isParam++
        else if token[0] is 'PARAM_END'
            @isParam--
        # We're not linting, just tracking function params.
        null
