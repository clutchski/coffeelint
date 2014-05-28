path = require 'path'
resolve = require('resolve').sync

# moduleName is a NodeJS module, or a path to a module NodeJS can load.
module.exports =

    loadFromConfig: (coffeelint, config) ->
        for ruleName, data of config when data?.module?
            @loadRule(coffeelint, data.module, ruleName)

    # moduleName is a NodeJS module, or a path to a module NodeJS can load.
    loadRule: (coffeelint, moduleName, ruleName = undefined) ->
        try
            try
                # Try to find the project-level rule first.
                rulePath = resolve moduleName, {
                    basedir: process.cwd()
                }
                ruleModule = require rulePath
            try
                # This seems awkward, but the ?= will prevent it from trying to
                # require if the previous step succeeded without an exception.
                #
                # Globally installed rule
                ruleModule ?= require moduleName

            # Maybe the user used a relative path from the command line. This
            # doesn't make much sense from a config file, but seems natural
            # with the --rules option.
            #
            # No try around this one, an exception here should abort the rest of
            # this function.
            ruleModule ?= require path.resolve(process.cwd(), moduleName)

            # Most rules can export as a single constructor function
            if typeof ruleModule is 'function'
                coffeelint.registerRule ruleModule, ruleName
            else
                # Or it can export an array of rules to load.
                for rule in ruleModule
                    coffeelint.registerRule rule
        catch e
            console.error "Error loading #{moduleName}"
            throw e
