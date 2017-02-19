isArrayInitializationUsingConstructor = (node, astApi) ->
    astApi.getNodeName(node?.value) is 'Op' and
        node.value.operator is 'new' and
        astApi.getNodeName(node.value.first) is 'Value' and
        node.value.first.base?.value is 'Array'

module.exports = class ArrayInitialization

    rule:
        name: 'array_initialization'
        level: 'ignore'
        message: 'Array initialization using the Array constructor is forbidden'
        description: """
            This rule forbids the use of the Array constructor for initializing
            arrays.
            Some insist on always using `[]` for initializing arrays.
            This rule is disabled by default.
            """

    lintAST: (node, astApi) ->
        @lintNode node, astApi
        undefined

    lintNode: (node, astApi) ->
        if isArrayInitializationUsingConstructor node, astApi
            error = astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error
        node.eachChild (child) => @lintNode child, astApi
