any = (arr, test) -> arr.reduce ((res, elt) -> res or test elt), false

module.exports = class NoUnnecessaryFatArrows

    rule:
        name: 'no_unnecessary_fat_arrows'
        level: 'warn'
        message: 'Unnecessary fat arrow'
        description: """
            Disallows defining functions with fat arrows when `this`
            is not used within the function.
            """

    lintAST: (node, @astApi) ->
        @lintNode node
        undefined

    lintNode: (node) ->
        if (@isFatArrowCode node) and (not @needsFatArrow node)
            error = @astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error
        node.eachChild (child) => @lintNode child

    isCode: (node) -> @astApi.getNodeName(node) is 'Code'
    isFatArrowCode: (node) -> @isCode(node) and node.bound
    isValue: (node) -> @astApi.getNodeName(node) is 'Value'

    isThis: (node) =>
        @isValue(node) and node.base.value is 'this'


    needsFatArrow: (node) =>
        @isCode(node) and (
            any(node.params, (param) => param.contains(@isThis)?) or
            node.body.contains(@isThis)? or
            node.body.contains((child) =>
                unless @astApi.getNodeName(child)
                    child.isSuper? and child.isSuper
                else
                    @isFatArrowCode(child) and @needsFatArrow(child))?
        )
