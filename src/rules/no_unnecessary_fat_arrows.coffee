isCode = (node) -> node.constructor.name is 'Code'
isFatArrowCode = (node) -> isCode(node) and node.bound
isThis = (node) ->
    node.constructor.name is 'Value' and node.base.value is 'this'

any = (arr, test) -> arr.reduce ((res, elt) -> res or test elt), false

needsFatArrow = (node) ->
    isCode(node) and (
        any(node.params, (param) -> param.contains(isThis)?) or
        node.body.contains(isThis)? or
        node.body.contains((child) ->
            isFatArrowCode(child) and needsFatArrow(child))?
    )

module.exports = class NoUnnecessaryFatArrows

    rule:
        name: 'no_unnecessary_fat_arrows'
        level: 'warn'
        message: 'Unnecessary fat arrow'
        description: """
            Disallows defining functions with fat arrows when `this`
            is not used within the function.
            """

    lintAST: (node, astApi) ->
        @lintNode node, astApi
        undefined

    lintNode: (node, astApi) ->
        if (isFatArrowCode node) and (not needsFatArrow node)
            error = astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error
        node.eachChild (child) => @lintNode child, astApi
