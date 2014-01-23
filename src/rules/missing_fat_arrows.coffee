isCode = (node) -> node?.constructor.name is 'Code'
isClass = (node) -> node.constructor.name is 'Class'
isValue = (node) -> node.constructor.name is 'Value'
isObject = (node) -> node.constructor.name is 'Obj'
isThis = (node) -> isValue(node) and node.base.value is 'this'
isFatArrowCode = (node) -> isCode(node) and node.bound

any = (arr, test) -> arr.reduce ((res, elt) -> res or test elt), false

needsFatArrow = (node) ->
    isCode(node) and (
        any(node.params, (param) -> param.contains(isThis)?) or
        node.body.contains(isThis)?
      )

methodsOfClass = (classNode) ->
    bodyNodes = classNode.body.expressions
    returnNode = bodyNodes[bodyNodes.length - 1]
    if returnNode? and isValue(returnNode) and isObject(returnNode.base)
        returnNode.base.properties
            .map((assignNode) -> assignNode.value)
            .filter(isCode)
    else []

module.exports = class MissingFatArrows

    rule:
        name: 'missing_fat_arrows'
        level: 'ignore'
        message: 'Used `this` in a function without a fat arrow'
        description: """
            Warns when you use `this` inside a function that wasn't defined
            with a fat arrow. This rule does not apply to methods defined in a
            class, since they have `this` bound to the class instance (or the
            class itself, for class methods).

            It is impossible to statically determine whether a function using
            `this` will be bound with the correct `this` value due to language
            features like `Function.prototype.call` and
            `Function.prototype.bind`, so this rule may produce false positives.
            """

    lintAST: (node, astApi) ->
        @lintNode node, astApi
        undefined

    lintNode: (node, astApi, methods = []) ->
        if (not isFatArrowCode node) and
                # Ignore any nodes we know to be methods
                (node not in methods) and
                (needsFatArrow node)
            error = astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error

        node.eachChild (child) => @lintNode child, astApi,
            switch
                when isClass node then methodsOfClass node
                # Once we've hit a function, we know we can't be in the top
                # level of a method anymore, so we can safely reset the methods
                # to empty to save work.
                when isCode node then []
                else methods
