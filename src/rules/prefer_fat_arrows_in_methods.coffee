
module.exports = class MissingFatArrows

    rule:
        name: 'prefer_fat_arrows_in_methods'
        level: 'ignore'
        message: 'Require fat arrows inside method bodies'
        description: """
            Warns when you do not use a fat arrow for functions defined inside
            method bodies. This assures that `this` is always bound to the
            method's object inside the code block of a method.
            """

    constructor: ->
        @insideMethod = [false]

    lintAST: (node, @astApi) ->
        @lintNode node
        undefined

    lintNode: (node, methods = []) ->
        if node in methods
            @insideMethod.push true
        else if @isClass node
            @insideMethod.push false
        else if (@isCode node) and @insideMethod[@insideMethod.length - 1] and
                not @isFatArrowCode node
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

        if node in methods or @isClass node
            @insideMethod.pop()

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
