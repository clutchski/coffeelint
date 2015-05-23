
module.exports = class NoClassFatArrows

    rule:
        name: 'no_class_fat_arrows'
        level: 'ignore'
        message: 'Used the fat arrow for an object method'
        description: """
            Warns when you use the fat arrow for an object method. This is
            useful for the code style where caller is expected to assure calls
            of object methods are bound with the correct `this` value.
            """

    lintAST: (node, @astApi) ->
        @lintNode node
        undefined

    lintNode: (node, methods = []) ->
        if @isFatArrowCode(node) and node in methods
            error = @astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error

        node.eachChild (child) => @lintNode child,
            switch
                when @isClass node then @methodsOfClass node
                # Once we've hit a function, we know we can't be in the top
                # level of a method anymore, so we can safely reset the methods
                # to empty to save work.
                when @isCode node then []
                else methods

    isCode: (node) => @astApi.getNodeName(node) is 'Code'
    isClass: (node) => @astApi.getNodeName(node) is 'Class'
    isValue: (node) => @astApi.getNodeName(node) is 'Value'
    isObject: (node) => @astApi.getNodeName(node) is 'Obj'
    isFatArrowCode: (node) => @isCode(node) and node.bound

    methodsOfClass: (classNode) ->
        bodyNodes = classNode.body.expressions
        returnNode = bodyNodes[bodyNodes.length - 1]
        if returnNode? and @isValue(returnNode) and @isObject(returnNode.base)
            returnNode.base.properties
                .map((assignNode) -> assignNode.value)
                .filter(@isCode)
        else []
