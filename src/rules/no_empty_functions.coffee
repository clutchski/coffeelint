isEmptyCode = (node, astApi) ->
    nodeName = astApi.getNodeName node
    nodeName is 'Code' and node.body.isEmpty()

module.exports = class NoEmptyFunctions

    rule:
        name: 'no_empty_functions'
        level: 'ignore'
        message: 'Empty function'
        description: """
            Disallows declaring empty functions.
            """

    lintAST: (node, astApi) ->
        @lintNode node, astApi
        undefined

    lintNode: (node, astApi) ->
        if isEmptyCode node, astApi
            error = astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error
        node.eachChild (child) => @lintNode child, astApi
