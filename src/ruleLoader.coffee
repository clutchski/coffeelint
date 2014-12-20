path = require 'path'
resolve = require('resolve').sync

# moduleName is a NodeJS module, or a path to a module NodeJS can load.
module.exports =
    require: (moduleName) ->
        try
            # Try to find the project-level rule first.
            rulePath = resolve moduleName, {
                basedir: process.cwd()
            }
            return require rulePath
        try
            # Globally installed rule
            return require moduleName
        try
            # Maybe the user used a relative path from the command line. This
            # doesn't make much sense from a config file, but seems natural
            # with the --rules option.
            #
            # No try around this one, an exception here should abort the rest of
            # this function.
            return require path.resolve(process.cwd(), moduleName)

        # This was already tried once. It will definitely fail, but it will
        # fail with a more sensible error message than the last require()
        # above.
        require moduleName

    loadFromConfig: (coffeelint, config) ->
        for ruleName, data of config when data?.module?
            @loadRule(coffeelint, data.module, ruleName)

    # moduleName is a NodeJS module, or a path to a module NodeJS can load.
    loadRule: (coffeelint, moduleName, ruleName = undefined) ->
        try
            ruleModule = @require moduleName

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
