
class LineApi
    constructor: (source, @config, @tokensByLine, @literate) ->
        @line = null
        @lines = source.split('\n')
        @lineCount = @lines.length

        # maintains some contextual information
        #   inClass: bool; in class or not
        #   lastUnemptyLineInClass: null or lineNumber, if the last not-empty
        #                     line was in a class it holds its number
        #   classIndents: the number of indents within a class
        @context = {
            class: {
                inClass: false
                lastUnemptyLineInClass: null
                classIndents: null
            }
        }

    lineNumber: 0

    isLiterate: -> @literate

    # maintain the contextual information for class-related stuff
    maintainClassContext: (line) ->
        if @context.class.inClass
            if @lineHasToken 'INDENT'
                @context.class.classIndents++
            else if @lineHasToken 'OUTDENT'
                @context.class.classIndents--
                if @context.class.classIndents is 0
                    @context.class.inClass = false
                    @context.class.classIndents = null
            if not line.match(/^\s*$/)
                @context.class.lastUnemptyLineInClass = @lineNumber
        else
            unless line.match(/\\s*/)
                @context.class.lastUnemptyLineInClass = null

            if @lineHasToken 'CLASS'
                @context.class.inClass = true
                @context.class.lastUnemptyLineInClass = @lineNumber
                @context.class.classIndents = 0

        null

    isLastLine: () ->
        return @lineNumber is @lineCount - 1

    # Return true if the given line actually has tokens.
    # Optional parameter to check for a specific token type and line number.
    lineHasToken: (tokenType = null, lineNumber = null) ->
        lineNumber = lineNumber ? @lineNumber
        unless tokenType?
            return @tokensByLine[lineNumber]?
        else
            tokens = @tokensByLine[lineNumber]
            return null unless tokens?
            for token in tokens
                return true if token[0] is tokenType
            return false

    # Return tokens for the given line number.
    getLineTokens: () ->
        @tokensByLine[@lineNumber] || []


BaseLinter = require './base_linter.coffee'

# Some repeatedly used regular expressions.
configStatement = /coffeelint:\s*((disable|enable)(-line)?)(?:=([\w\s,]*))?/
configShortcuts = [
    # TODO: make this user (and / or api) configurable
    [/\#.*noqa/, 'coffeelint: disable-line']
]

#
# A class that performs regex checks on each line of the source.
#
module.exports = class LineLinter extends BaseLinter

    @getDirective: (line) ->
        for [shortcut, replacement] in configShortcuts
            if line.match(shortcut)
                return configStatement.exec(replacement)
        return configStatement.exec(line)

    constructor: (source, config, rules, tokensByLine, literate = false) ->
        super source, config, rules

        @lineApi = new LineApi source, config, tokensByLine, literate

        # Store suppressions in the form of { line #: type }
        @inlineConfig =
            enable: {}
            disable: {}
            'enable-line': {}
            'disable-line': {}

    acceptRule: (rule) ->
        return typeof rule.lintLine is 'function'

    lint: () ->
        errors = []
        for line, lineNumber in @lineApi.lines
            @lineApi.lineNumber = @lineNumber = lineNumber
            @lineApi.line = @lineApi.lines[lineNumber]
            @lineApi.maintainClassContext line
            @collectInlineConfig line

            errors.push(error) for error in @lintLine(line)
        errors

    # Return an error if the line contained failed a rule, null otherwise.
    lintLine: (line) ->

        # Multiple rules might run against the same line to build context.
        # Every every rule should run even if something has already produced an
        # error for the same token.
        errors = []
        for rule in @rules
            v = @normalizeResult rule, rule.lintLine(line, @lineApi)
            errors.push v if v?
        errors

    collectInlineConfig: (line) ->
        # Check for block config statements enable and disable
        result = @constructor.getDirective(line)
        if result?
            cmd = result[1]
            rules = []
            if result[4]?
                for r in result[4].split(',')
                    rules.push r.replace(/^\s+|\s+$/g, '')
            @inlineConfig[cmd][@lineNumber] = rules
        return null


    createError: (rule, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1 # Lines are indexed by zero.
        attrs.level = @config[rule]?.level
        super rule, attrs
