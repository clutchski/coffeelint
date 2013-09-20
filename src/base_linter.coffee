# Patch the source properties onto the destination.
extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination

# Patch any missing attributes from defaults to source.
defaults = (source, defaults) ->
    extend({}, defaults, source)

module.exports = class BaseLinter

    constructor: (@source, @config, rules) ->
        @setupRules rules

    isObject: (obj) ->
        obj is Object(obj)

    # Create an error object for the given rule with the given
    # attributes.
    createError: (ruleName, attrs = {}) ->

        # Level should default to what's in the config, but can be overridden.
        attrs.level ?= @config[ruleName].level

        level = attrs.level
        if level not in ['ignore', 'warn', 'error']
            throw new Error("unknown level #{level}")

        if level in ['error', 'warn']
            attrs.rule = ruleName
            return defaults(attrs, @config[ruleName])
        else
            null

    acceptRule: (rule) ->
        throw new Error "acceptRule needs to be overridden in the subclass"

    # Only rules that have a level of error or warn will even get constructed.
    setupRules: (rules) ->
        @rules = []
        for name, RuleConstructor of rules
            level = @config[name].level
            if level in ['error', 'warn']
                rule = new RuleConstructor this, @config
                if @acceptRule(rule)
                    @rules.push rule
            else if level isnt 'ignore'
                throw new Error("unknown level #{level}")

    normalizeResult: (p, result) ->
        if result is true
            return @createError p.rule.name
        if @isObject result
            return @createError p.rule.name, result
