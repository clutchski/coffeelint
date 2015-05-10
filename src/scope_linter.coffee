BaseLinter = require './base_linter.coffee'
cofeescope = require('coffeescope')

class ScopeApi
    createError: ->
        # See below, this gets replaced with a version that knows the rule name


module.exports = class ASTLinter extends BaseLinter

    constructor : (source, config, rules) ->
        super source, config, rules
        @scopeApi = new ScopeApi @config

    acceptRule: (rule) ->
        return typeof rule.lintScope is 'function'

    lint : () ->
        errors = []

        for rule in @rules
            @scopeApi.createError = (attrs = {}) =>
                @createError rule.rule.name, attrs

            # HACK: Push the local errors object into the plugin. This is a
            # temporary solution until I have a way for it to really return
            # multiple errors.
            rule.errors = errors

            globalScope = coffeescope(@source)

            rule.lintScope(@node, @scopeApi)
        errors
