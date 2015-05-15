BaseLinter = require './base_linter.coffee'
coffeescope = require('coffeescope')

class ScopeApi
    constructor: (@config) ->
    createError: ->
        # See below, this gets replaced with a version that knows the rule name


module.exports = class ScopeLinter extends BaseLinter

    constructor : (source, config, rules, @CoffeeScript) ->
        super source, config, rules
        @scopeApi = new ScopeApi @config

    acceptRule: (rule) ->
        return typeof rule.lintScope is 'function'

    lint : () ->
        errors = []

        try
            globalScope = coffeescope.scan(@CoffeeScript, @source)
        catch error
            return [@createError('coffeelint', {
                message: "CoffeeScope Error: #{error.message}"
                level: 'warn'
                lineNumber: 1
            })]

        for rule in @rules
            ruleName = rule.rule.name
            @scopeApi.createError = (attrs = {}) =>
                @createError rule.rule.name, attrs

            # HACK: Push the local errors object into the plugin. This is a
            # temporary solution until I have a way for it to really return
            # multiple errors.
            rule.errors = errors

            try
                rule.lintScope(globalScope, @scopeApi)
            catch error
                errors.push(@createError('coffeelint', {
                    message: "#{ruleName} Error: #{error.message}"
                    level: 'warn'
                    lineNumber: 1
                }))

        errors
