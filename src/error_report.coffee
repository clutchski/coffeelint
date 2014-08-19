
# A summary of errors in a CoffeeLint run.
module.exports = class ErrorReport

    constructor : (@coffeelint) ->
        @paths = {}

    lint: (filename, source, config = {}, literate = false) ->
        @paths[filename] = @coffeelint.lint(source, config, literate)

    getExitCode : () ->
        for path of @paths
            return 1 if @pathHasError(path)
        return 0

    getSummary : () ->
        pathCount = errorCount = warningCount = 0
        for path, errors of @paths
            pathCount++
            for error in errors
                errorCount++ if error.level is 'error'
                warningCount++ if error.level is 'warn'
        return {errorCount, warningCount, pathCount}

    getErrors : (path) ->
        return @paths[path]

    pathHasWarning : (path) ->
        return @_hasLevel(path, 'warn')

    pathHasError : (path) ->
        return @_hasLevel(path, 'error')

    hasError : () ->
        for path of @paths
            return true if @pathHasError(path)
        return false

    _hasLevel : (path, level) ->
        for error in @paths[path]
            return true if error.level is level
        return false

