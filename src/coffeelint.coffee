###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


# Coffeelint's namespace.
# Browserify wrapps this file in a UMD that will set window.coffeelint to
# exports
coffeelint = exports

if window?
    # If we're in the browser assume CoffeeScript is already loaded.
    CoffeeScript = window.CoffeeScript
else
    # By storing this in a variable it prevents browserify from finding this
    # dependency. If it isn't hidden there is an error attempting to inline
    # CoffeeScript.  if browserify uses `-i` to ignore the dependency it
    # creates an empty shim which breaks NodeJS
    # https://github.com/substack/node-browserify/issues/471
    cs = 'coffee-script'
    CoffeeScript = require cs


# The current version of Coffeelint.
coffeelint.VERSION = "0.5.7"


# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'

coffeelint.RULES = RULES = require './rules.coffee'


# Some repeatedly used regular expressions.
regexes =
    configStatement : /coffeelint:\s*(disable|enable)(?:=([\w\s,]*))?/


# Patch the source properties onto the destination.
extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination

# Patch any missing attributes from defaults to source.
defaults = (source, defaults) ->
    extend({}, defaults, source)

isObject = (obj) ->
    obj is Object(obj)

# Create an error object for the given rule with the given
# attributes.
createError = (rule, attrs = {}) ->
    level = attrs.level
    if level not in [IGNORE, WARN, ERROR]
        throw new Error("unknown level #{level}")

    if level in [ERROR, WARN]
        attrs.rule = rule
        return defaults(attrs, RULES[rule])
    else
        null

# Store suppressions in the form of { line #: type }
block_config =
    enable : {}
    disable : {}

#
# A class that performs regex checks on each line of the source.
#
class LineLinter

    constructor : (source, config, tokensByLine, rules) ->
        @source = source
        @config = config
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
                return @createLineError p.rule.name
            if isObject v
                return @createLineError p.rule.name, v

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
            block_config[cmd][@lineNumber] = rules
        return null


    createLineError : (rule, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1 # Lines are indexed by zero.
        attrs.level = @config[rule]?.level
        createError(rule, attrs)

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

#
# A class that performs checks on the output of CoffeeScript's lexer.
#
class LexicalLinter

    constructor : (source, config, rules) ->
        @source = source
        @tokens = CoffeeScript.tokens(source)
        @config = config
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
                return @createLexError p.rule.name
            if isObject v
                return @createLexError p.rule.name, v

        # Now lint it.
        switch type
            when "UNARY"                  then @lintUnary(token)
            else null

    lintUnary : (token) ->
        if token[1] is 'new'
            # Find the last chained identifier, e.g. Bar in new foo.bar.Bar().
            identifierIndex = 1
            loop
                expectedIdentifier = @peek(identifierIndex)
                expectedCallStart  = @peek(identifierIndex + 1)
                if expectedIdentifier?[0] is 'IDENTIFIER'
                    if expectedCallStart?[0] is '.'
                        identifierIndex += 2
                        continue
                break

            # The callStart is generated if your parameters are all on the same
            # line with implicit parens, and if your parameters start on the
            # next line, but is missing if there are no params and no parens.
            if expectedIdentifier?[0] is 'IDENTIFIER' and expectedCallStart?
                if expectedCallStart[0] is 'CALL_START'
                    if expectedCallStart.generated
                        @createLexError('non_empty_constructor_needs_parens')
                else
                    @createLexError('empty_constructor_needs_parens')


    createLexError : (rule, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1
        attrs.level = @config[rule].level
        attrs.line = @lines[@lineNumber]
        createError(rule, attrs)

    # Return the token n places away from the current token.
    peek : (n = 1) ->
        @tokens[@i + n] || null


# A class that performs static analysis of the abstract
# syntax tree.
class ASTLinter

    constructor : (source, config) ->
        @source = source
        @config = config
        @errors = []

    lint : () ->
        try
            @node = CoffeeScript.nodes(@source)
        catch coffeeError
            @errors.push @_parseCoffeeScriptError(coffeeError)
            return @errors
        @lintNode(@node)
        @errors

    # returns the "complexity" value of the current node.
    getComplexity : (node) ->
        name = node.constructor.name
        complexity = if name in ['If', 'While', 'For', 'Try']
            1
        else if name == 'Op' and node.operator in ['&&', '||']
            1
        else if name == 'Switch'
            node.cases.length
        else
            0
        return complexity

    # Lint the AST node and return its cyclomatic complexity.
    lintNode : (node, line) ->

        # Get the complexity of the current node.
        name = node.constructor.name
        complexity = @getComplexity(node)

        # Add the complexity of all child's nodes to this one.
        node.eachChild (childNode) =>
            nodeLine = childNode.locationData.first_line
            complexity += @lintNode(childNode, nodeLine) if childNode

        # If the current node is a function, and it's over our limit, add an
        # error to the list.
        rule = @config.cyclomatic_complexity

        if name == 'Code' and complexity >= rule.value
            attrs = {
                context: complexity + 1
                level: rule.level
                lineNumber: line + 1
                lineNumberEnd: node.locationData.last_line + 1
            }
            error = createError 'cyclomatic_complexity', attrs
            @errors.push error if error

        # Return the complexity for the benefit of parent nodes.
        return complexity

    _parseCoffeeScriptError : (coffeeError) ->
        rule = RULES['coffeescript_error']

        message = coffeeError.toString()

        # Parse the line number
        lineNumber = -1
        if coffeeError.location?
            lineNumber = coffeeError.location.first_line + 1
        else
            match = /line (\d+)/.exec message
            lineNumber = parseInt match[1], 10 if match?.length > 1
        attrs = {
            message: message
            level: rule.level
            lineNumber: lineNumber
        }
        return  createError 'coffeescript_error', attrs



# Merge default and user configuration.
mergeDefaultConfig = (userConfig) ->
    config = {}
    for rule, RuleConstructor of _rules
        tmp = new RuleConstructor
        RULES[rule] = tmp.rule

    for rule, ruleConfig of RULES
        config[rule] = defaults(userConfig[rule], ruleConfig)


    return config

coffeelint.invertLiterate = (source) ->
    source = CoffeeScript.helpers.invertLiterate source
    # Strip the first 4 spaces from every line. After this the markdown is
    # commented and all of the other code should be at their natural location.
    newSource = ""
    for line in source.split "\n"
        if line.match(/^#/)
            # strip trailing space
            line = line.replace /\s*$/, ''
        # Strip the first 4 spaces of every line. This is how Markdown
        # indicates code, so in the end this pulls everything back to where it
        # would be indented if it hadn't been written in literate style.
        line = line.replace /^\s{4}/g, ''
        newSource += "#{line}\n"

    newSource

_rules = {}
coffeelint.registerRule = (RuleConstructor) ->
    p = new RuleConstructor

    name = p?.rule?.name
    e = (msg) -> throw new Error "Invalid rule: #{name} #{msg}"
    unless p.rule?
        e "Rules must provide rule attribute with a default configuration."

    e "Rule defaults require a name" unless p.rule.name?

    e "Rule defaults require a message" unless p.rule.message?
    e "Rule defaults require a description" unless p.rule.description?
    unless p.rule.level in [ 'ignore', 'warn', 'error' ]
        e "Default level must be 'ignore', 'warn', or 'error'"

    if typeof p.lintToken is 'function'
        e "'tokens' is required for 'lintToken'" unless p.tokens
    else if typeof p.lintLine  isnt 'function'
        e "Rules must implement lintToken or lintLine"


    _rules[p.rule.name] = RuleConstructor

# These all need to be explicitly listed so they get picked up by browserify.
coffeelint.registerRule require './rules/arrow_spacing.coffee'
coffeelint.registerRule require './rules/no_tabs.coffee'
coffeelint.registerRule require './rules/no_trailing_whitespace.coffee'
coffeelint.registerRule require './rules/max_line_length.coffee'
coffeelint.registerRule require './rules/line_endings.coffee'
coffeelint.registerRule require './rules/no_trailing_semicolons.coffee'
coffeelint.registerRule require './rules/indentation.coffee'
coffeelint.registerRule require './rules/camel_case_classes.coffee'
coffeelint.registerRule require './rules/no_implicit_braces.coffee'
coffeelint.registerRule require './rules/no_plusplus.coffee'
coffeelint.registerRule require './rules/no_throwing_strings.coffee'
coffeelint.registerRule require './rules/no_backticks.coffee'
coffeelint.registerRule require './rules/no_implicit_parens.coffee'
coffeelint.registerRule require './rules/no_empty_param_list.coffee'
coffeelint.registerRule require './rules/no_stand_alone_at.coffee'
coffeelint.registerRule require './rules/space_operators.coffee'
coffeelint.registerRule require './rules/duplicate_key.coffee'

# Check the source against the given configuration and return an array
# of any errors found. An error is an object with the following
# properties:
#
#   {
#       rule :      'Name of the violated rule',
#       lineNumber: 'Number of the line that caused the violation',
#       level:      'The error level of the violated rule',
#       message:    'Information about the violated rule',
#       context:    'Optional details about why the rule was violated'
#   }
#
coffeelint.lint = (source, userConfig = {}, literate = false) ->
    source = @invertLiterate source if literate

    config = mergeDefaultConfig(userConfig)

    # Check ahead for inline enabled rules
    disabled_initially = []
    for l in source.split('\n')
        s = regexes.configStatement.exec(l)
        if s?.length > 2 and 'enable' in s
            for r in s[1..]
                unless r in ['enable','disable']
                    unless r of config and config[r].level in ['warn','error']
                        disabled_initially.push r
                        config[r] = { level: 'error' }

    # Do AST linting first so all compile errors are caught.
    astErrors = new ASTLinter(source, config).lint()

    # Do lexical linting.
    lexicalLinter = new LexicalLinter(source, config, _rules)
    lexErrors = lexicalLinter.lint()

    # Do line linting.
    tokensByLine = lexicalLinter.tokensByLine
    lineLinter = new LineLinter(source, config, tokensByLine, _rules)
    lineErrors = lineLinter.lint()

    # Sort by line number and return.
    errors = lexErrors.concat(lineErrors, astErrors)
    errors.sort((a, b) -> a.lineNumber - b.lineNumber)

    # Helper to remove rules from disabled list
    difference = (a, b) ->
        j = 0
        while j < a.length
            if a[j] in b
                a.splice(j, 1)
            else
                j++

    # Disable/enable rules for inline blocks
    all_errors = errors
    errors = []
    disabled = disabled_initially
    next_line = 0
    for i in [0...source.split('\n').length]
        for cmd of block_config
            rules = block_config[cmd][i]
            {
                'disable': ->
                    disabled = disabled.concat(rules)
                'enable': ->
                    difference(disabled, rules)
                    disabled = disabled_initially if rules.length is 0
            }[cmd]() if rules?
        # advance line and append relevant messages
        while next_line is i and all_errors.length > 0
            next_line = all_errors[0].lineNumber - 1
            e = all_errors[0]
            if e.lineNumber is i + 1 or not e.lineNumber?
                e = all_errors.shift()
                errors.push e unless e.rule in disabled

    block_config =
      'enable': {}
      'disable': {}

    errors
