module.exports = class NoPrivateFunctionFatArrows

    rule:
        name: 'no_private_function_fat_arrows'
        level: 'warn'
        message: 'Used the fat arrow for a private function'
        description: '''
            Warns when you use the fat arrow for a private function
            inside a class definition scope. It is not necessary and
            it does not do anything.
            '''

    lintAST: (node, @astApi) ->
        @lintNode node
        undefined

    lintNode: (node, functions = []) ->
        if @isFatArrowCode(node) and node in functions
            error = @astApi.createError
                lineNumber: node.locationData.first_line + 1
            @errors.push error

        node.eachChild (child) => @lintNode child,
            switch
                when @isClass node then @functionsOfClass node
                # Once we've hit a function, we know we can't be in the top
                # level of a function anymore, so we can safely reset the
                # functions to empty to save work.
                when @isCode node then []
                else functions

    isCode: (node) => @astApi.getNodeName(node) is 'Code'
    isClass: (node) => @astApi.getNodeName(node) is 'Class'
    isValue: (node) => @astApi.getNodeName(node) is 'Value'
    isObject: (node) => @astApi.getNodeName(node) is 'Obj'
    isFatArrowCode: (node) => @isCode(node) and node.bound

    functionsOfClass: (classNode) ->
        bodyValues = for bodyNode in classNode.body.expressions
            continue if @isValue(bodyNode) and @isObject(bodyNode.base)

            bodyNode.value
        bodyValues.filter(@isCode)
