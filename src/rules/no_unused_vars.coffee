
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
        name: 'no_unused_vars'
        description: '''
        Finds unused variables.
        '''
        # Yes, args is modeled after ESLint's rule:
        # http://eslint.org/docs/rules/no-unused-vars
        args: 'after-used' # may also be 'all' or 'none'
        level: 'warn'
        message: 'Unused variable'

    lintScope: (globalScope, @scopeApi) ->
        @config = @scopeApi.config[@rule.name]
        @scanScope(globalScope)

    scanScope: (scope) =>
        for name, { paramIndex, locationData } of scope.variables
            # Global variables don't have locationData
            if not locationData?
                continue

            # Don't scan arguments
            if @config.args is 'none' and paramIndex?
                continue

            referenced = hasBeenReferenced(name, scope)

            # If a parameter later in the list is used, then this one is
            # necessary as a placeholder
            if not referenced and paramIndex? and @config.args is 'after-used'
                for tmpName, tmp of scope.variables
                    if tmp.paramIndex > paramIndex and
                            hasBeenReferenced(tmpName, scope)
                        referenced = true

            if not referenced
                @errors.push @scopeApi.createError {
                    context: name
                    lineNumber: locationData.first_line + 1
                }

        for s in (scope.scopes ? [])
            @scanScope(s)
