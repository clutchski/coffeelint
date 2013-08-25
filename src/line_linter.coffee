
BaseLinter = require './base_linter.coffee'

# Some repeatedly used regular expressions.
regexes =
    configStatement : /coffeelint:\s*(disable|enable)(?:=([\w\s,]*))?/

#
# A class that performs regex checks on each line of the source.
#
module.exports = class LineLinter extends BaseLinter

    constructor : (source, config, tokensByLine, rules) ->
        super source, config

        # Store suppressions in the form of { line #: type }
        @block_config =
            enable : {}
            disable : {}
        @line = null
        @lineNumber = 0
        @tokensByLine = tokensByLine
        @lines = @source.split('\n')
        @lineCount = @lines.length

        # maintains some contextual information
        #   inClass: bool; in class or not
        #   lastUnemptyLineInClass: null or lineNumber, if the last not-empty
        #                     line was in a class it holds its number
        #   classIndents: the number of indents within a class
        @context = {
            class: {
                inClass : false
                lastUnemptyLineInClass : null
                classIndents : null
            }
        }
        @setupRules(rules)

    # Only rules that have a level of error or warn will even get constructed.
    setupRules: (rules) ->
        @rules = []
        for name, RuleConstructor of rules
            level = @config[name].level
            if level in ['error', 'warn']
                rule = new RuleConstructor this, @config
                if typeof rule.lintLine is 'function'
                    @rules.push rule
            else if level isnt 'ignore'
                throw new Error("unknown level #{level}")

    lint : () ->
        errors = []
        for line, lineNumber in @lines
            @lineNumber = lineNumber
            @line = line
            @maintainClassContext()
            error = @lintLine()
            errors.push(error) if error
        errors

    # Return an error if the line contained failed a rule, null otherwise.
    lintLine : () ->
        @collectInlineConfig()

        for p in @rules
            # tokenApi is *temporarily* the lexicalLinter. I think it should be
            # separated.
            v = p.lintLine @line, this
            if v is true
                return @createError p.rule.name
            if @isObject v
                return @createError p.rule.name, v

        undefined

    collectInlineConfig : () ->
        # Check for block config statements enable and disable
        result = regexes.configStatement.exec(@line)
        if result?
            cmd = result[1]
            rules = []
            if result[2]?
                for r in result[2].split(',')
                    rules.push r.replace(/^\s+|\s+$/g, "")
            @block_config[cmd][@lineNumber] = rules
        return null


    createError: (rule, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1 # Lines are indexed by zero.
        attrs.level = @config[rule]?.level
        super rule, attrs

    isLastLine : () ->
        return @lineNumber == @lineCount - 1

    # Return true if the given line actually has tokens.
    # Optional parameter to check for a specific token type and line number.
    lineHasToken : (tokenType = null, lineNumber = null) ->
        lineNumber = lineNumber ? @lineNumber
        unless tokenType?
            return @tokensByLine[lineNumber]?
        else
            tokens = @tokensByLine[lineNumber]
            return null unless tokens?
            for token in tokens
                return true if token[0] == tokenType
            return false

    # Return tokens for the given line number.
    getLineTokens : () ->
        @tokensByLine[@lineNumber] || []

    # maintain the contextual information for class-related stuff
    maintainClassContext : () ->
        if @context.class.inClass
            if @lineHasToken 'INDENT'
                @context.class.classIndents++
            else if @lineHasToken 'OUTDENT'
                @context.class.classIndents--
                if @context.class.classIndents is 0
                    @context.class.inClass = false
                    @context.class.classIndents = null

            if @context.class.inClass and not @line.match( /^\s*$/ )
                @context.class.lastUnemptyLineInClass = @lineNumber
        else
            unless @line.match(/\\s*/)
                @context.class.lastUnemptyLineInClass = null

            if @lineHasToken 'CLASS'
                @context.class.inClass = true
                @context.class.lastUnemptyLineInClass = @lineNumber
                @context.class.classIndents = 0

        null