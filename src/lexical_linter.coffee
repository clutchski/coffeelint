
class TokenApi
    constructor: (CoffeeScript, source, @config, @tokensByLine) ->
        @tokens = CoffeeScript.tokens(source)
        @lines = source.split('\n')
        @tokensByLine = {}  # A map of tokens by line.

    i: 0              # The index of the current token we're linting.

    # Return the token n places away from the current token.
    peek : (n = 1) ->
        @tokens[@i + n] || null


BaseLinter = require './base_linter.coffee'

#
# A class that performs checks on the output of CoffeeScript's lexer.
#
module.exports = class LexicalLinter extends BaseLinter

    constructor : (source, config, rules, CoffeeScript) ->
        super source, config, rules

        @tokenApi = new TokenApi CoffeeScript, source, @config, @tokensByLine
        # This needs to be available on the LexicalLinter so it can be passed
        # to the LineLinter when this finishes running.
        @tokensByLine = @tokenApi.tokensByLine

    acceptRule: (rule) ->
        return typeof rule.lintToken is 'function'

    # Return a list of errors encountered in the given source.
    lint : () ->
        errors = []

        for token, i in @tokenApi.tokens
            @tokenApi.i = i
            errors.push(error) for error in @lintToken(token)
        errors


    # Return an error if the given token fails a lint check, false otherwise.
    lintToken : (token) ->
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

        @tokenApi.lineNumber = @lineNumber

        # Multiple rules might run against the same token to build context.
        # Every every rule should run even if something has already produced an
        # error for the same token.
        errors = []
        for rule in @rules when token[0] in rule.tokens
            v = @normalizeResult rule, rule.lintToken(token, @tokenApi)
            errors.push v if v?
        errors

    createError : (ruleName, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1
        attrs.line = @tokenApi.lines[@lineNumber]
        super ruleName, attrs

