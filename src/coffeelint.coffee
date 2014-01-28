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

# Browserify will inline the file at compile time.
packageJSON = require('./../package.json')

# The current version of Coffeelint.
coffeelint.VERSION = packageJSON.version


# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'

coffeelint.RULES = RULES = require './rules.coffee'

# Patch the source properties onto the destination.
extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination

# Patch any missing attributes from defaults to source.
defaults = (source, defaults) ->
    extend({}, defaults, source)

# Helper to remove rules from disabled list
difference = (a, b) ->
    j = 0
    while j < a.length
        if a[j] in b
            a.splice(j, 1)
        else
            j++

LineLinter = require './line_linter.coffee'
LexicalLinter = require './lexical_linter.coffee'
ASTLinter = require './ast_linter.coffee'

# Merge default and user configuration.
mergeDefaultConfig = (userConfig) ->
    config = {}
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
coffeelint.registerRule = (RuleConstructor, ruleName = undefined) ->
    p = new RuleConstructor

    name = p?.rule?.name or "(unknown)"
    e = (msg) -> throw new Error "Invalid rule: #{name} #{msg}"
    unless p.rule?
        e "Rules must provide rule attribute with a default configuration."

    e "Rule defaults require a name" unless p.rule.name?

    if ruleName? and ruleName isnt p.rule.name
        e "Mismatched rule name: #{ruleName}"

    e "Rule defaults require a message" unless p.rule.message?
    e "Rule defaults require a description" unless p.rule.description?
    unless p.rule.level in [ 'ignore', 'warn', 'error' ]
        e "Default level must be 'ignore', 'warn', or 'error'"

    if typeof p.lintToken is 'function'
        e "'tokens' is required for 'lintToken'" unless p.tokens
    else if typeof p.lintLine  isnt 'function' and
            typeof p.lintAST isnt 'function'
        e "Rules must implement lintToken, lintLine, or lintAST"

    # Capture the default options for the new rule.
    RULES[p.rule.name] = p.rule
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
coffeelint.registerRule require './rules/colon_assignment_spacing.coffee'
coffeelint.registerRule require './rules/no_implicit_braces.coffee'
coffeelint.registerRule require './rules/no_plusplus.coffee'
coffeelint.registerRule require './rules/no_throwing_strings.coffee'
coffeelint.registerRule require './rules/no_backticks.coffee'
coffeelint.registerRule require './rules/no_implicit_parens.coffee'
coffeelint.registerRule require './rules/no_empty_param_list.coffee'
coffeelint.registerRule require './rules/no_stand_alone_at.coffee'
coffeelint.registerRule require './rules/space_operators.coffee'
coffeelint.registerRule require './rules/duplicate_key.coffee'
coffeelint.registerRule require './rules/empty_constructor_needs_parens.coffee'
coffeelint.registerRule require './rules/cyclomatic_complexity.coffee'
coffeelint.registerRule require './rules/newlines_after_classes.coffee'
coffeelint.registerRule require './rules/no_unnecessary_fat_arrows.coffee'
coffeelint.registerRule require './rules/missing_fat_arrows.coffee'
coffeelint.registerRule(
    require './rules/non_empty_constructor_needs_parens.coffee'
)

hasSyntaxError = (source) ->
    try
        # If there are syntax errors this will abort the lexical and line
        # linters.
        CoffeeScript.tokens(source)
        return false
    return true

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
        s = LineLinter.configStatement.exec(l)
        if s?.length > 2 and 'enable' in s
            for r in s[1..]
                unless r in ['enable','disable']
                    unless r of config and config[r].level in ['warn','error']
                        disabled_initially.push r
                        config[r] = { level: 'error' }

    # Do AST linting first so all compile errors are caught.
    astErrors = new ASTLinter(source, config, _rules, CoffeeScript).lint()
    errors = [].concat(astErrors)

    # only do further checks if the syntax is okay, otherwise they just fail
    # with syntax error exceptions
    unless hasSyntaxError(source)
        # Do lexical linting.
        lexicalLinter = new LexicalLinter(source, config, _rules, CoffeeScript)
        lexErrors = lexicalLinter.lint()
        errors = errors.concat(lexErrors)

        # Do line linting.
        tokensByLine = lexicalLinter.tokensByLine
        lineLinter = new LineLinter(source, config, _rules, tokensByLine,
            literate)
        lineErrors = lineLinter.lint()
        errors = errors.concat(lineErrors)
        block_config = lineLinter.block_config
    else
        # default this so it knows what to do
        block_config =
            enable : {}
            disable : {}

    # Sort by line number and return.
    errors.sort((a, b) -> a.lineNumber - b.lineNumber)

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

    errors
