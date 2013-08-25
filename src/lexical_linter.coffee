
BaseLinter = require './base_linter.coffee'

#
# A class that performs checks on the output of CoffeeScript's lexer.
#
module.exports = class LexicalLinter extends BaseLinter

    constructor : (source, config, CoffeeScript, rules) ->
        super source, config
        @tokens = CoffeeScript.tokens(source)
        @i = 0              # The index of the current token we're linting.
        @tokensByLine = {}  # A map of tokens by line.
        @lines = source.split('\n')
        @setupRules(rules)


    # Only plugins that have a level of error or warn will even get constructed.
    setupRules: (rules) ->
        @rules = []
        for name, RuleConstructor of rules
            level = @config[name].level
            if level in ['error', 'warn']
                rule = new RuleConstructor this, @config
                if typeof rule.lintToken is 'function'
                    @rules.push rule
            else if level isnt 'ignore'
                throw new Error("unknown level #{level}")

    # Return a list of errors encountered in the given source.
    lint : () ->
        errors = []

        for token, i in @tokens
            @i = i
            error = @lintToken(token)
            errors.push(error) if error
        errors


    # Return an error if the given token fails a lint check, false otherwise.
    lintToken : (token) -> # Arrow intentionally spaced wrong for testing.
        [type, value, lineNumber] = token

        if typeof lineNumber == "object"
            if type == 'OUTDENT' or type == 'INDENT'
                lineNumber = lineNumber.last_line
            else
                lineNumber = lineNumber.first_line
        @tokensByLine[lineNumber] ?= []
        @tokensByLine[lineNumber].push(token)
        # CoffeeScript loses line numbers of interpolations and multi-line
        # regexes, so fake it by using the last line number we know.
        @lineNumber = lineNumber or @lineNumber or 0

        for p in @rules when token[0] in p.tokens
            # tokenApi is *temporarily* the lexicalLinter. I think it should be
            # separated.
            v = p.lintToken token, this
            if v is true
                return @createError p.rule.name
            if @isObject v
                return @createError p.rule.name, v

    createError : (ruleName, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1
        attrs.level = @config[ruleName].level
        attrs.line = @lines[@lineNumber]
        super ruleName, attrs

    # Return the token n places away from the current token.
    peek : (n = 1) ->
        @tokens[@i + n] || null
