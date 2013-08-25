# Patch the source properties onto the destination.
extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination

# Patch any missing attributes from defaults to source.
defaults = (source, defaults) ->
    extend({}, defaults, source)

module.exports = class BaseLinter

    constructor: (@config) ->


    isObject: (obj) ->
        obj is Object(obj)

    # Create an error object for the given rule with the given
    # attributes.
    createError: (ruleName, attrs = {}) ->
        level = attrs.level
        if level not in ['ignore', 'warn', 'error']
            throw new Error("unknown level #{level}")

        if level in ['error', 'warn']
            attrs.rule = ruleName
            return defaults(attrs, @config[ruleName])
        else
            null
