
isReferenceTo = (target) ->
    return (ref) -> ref.name is target

hasBeenReferenced = (variable, scope) ->
    references = scope.references.filter(isReferenceTo(variable))
    if references.length > 0
        return true

    for s in (scope.scopes ? []) when hasBeenReferenced(variable, s)
        return true
    return false

module.exports = class UnusedVariable
    rule:
        name: 'no_undefined_vars'
        description: '''
        Finds undefined variables.
        '''
        environments: {}
        level: 'error'
        message: 'Undefined variable'

    lintScope: (globalScope, @scopeApi) ->
        @config = @scopeApi.config[@rule.name]
        @scanScope(globalScope)

    scanScope: (scope) =>
        if not scope.scopeChain?
            throw new Error('Missing scopeChain')

        for {name, locationData } in scope.references
            if not scope.scopeChain[name]?
                @errors.push @scopeApi.createError {
                    context: name
                    lineNumber: locationData.first_line + 1
                }

        for s in (scope.scopes ? [])
            @scanScope(s)
