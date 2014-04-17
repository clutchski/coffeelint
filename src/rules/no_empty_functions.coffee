isEmptyCode = (node, astApi) ->
    nodeName = astApi.getNodeName node
    nodeName is 'Code' and node.body.isEmpty()

module.exports = class NoEmptyFunctions

    rule:
        name: 'no_empty_functions'
        level: 'ignore'
        message: 'Empty function'
        description: """
            Disallows declaring empty functions. The goal of this rule is that
            unintentional empty callbacks can be detected:
            <pre>
            <code>someFunctionWithCallback ->
            doSomethingSignificant()
            </code>
            </pre>
            The problem is that the call to
            <tt>doSomethingSignificant</tt> will be made regardless
            of <tt>someFunctionWithCallback</tt>'s execution. It can
            be because you did not indent the call to
            <tt>doSomethingSignificant</tt> properly.

            If you really meant that <tt>someFunctionWithCallback</tt>
            should call a callback that does nothing, you can write your code
            this way:
            <pre>
            <code>someFunctionWithCallback ->
                undefined
            doSomethingSignificant()
            </code>
            </pre>
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
