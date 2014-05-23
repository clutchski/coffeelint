
module.exports = class NoForOverwrite

    rule:
        name: 'no_for_overwrite'
        level: 'ignore'
        message: 'Overwriting variable in for statement is forbidden.'
        description: """
            This rule prohibits overwriting variables in for loops to avoid
            the following type of errors:
            <pre>
            <code>path = require 'path'
            foo ->
              for path in ['a', 'b', 'c'] # forbidden
                console.log path
            foo()
            console.log path.join 'a', 'b' # will throw as path is 'c'
            </code>
            </pre>
            This rule is ignored by default.
            """

    lintAST: (node, @astApi) ->
        @lintNode node, [{}]
        undefined

    isVariableUsed: (stack, name) ->
        result = false
        for entry in stack by -1
            if entry[name] is true
                result = true
                break
        result

    lintNode: (node, stack) ->
        top = stack[stack.length - 2]
        name = @astApi?.getNodeName node

        switch

            # If we're in "for ..."
            when name is 'For'

                # Get variable and index variable names
                variables = []
                variables.push node.name.value if node.name?
                variables.push node.index.value if node.index?

                # Check if they were used before
                for variable in variables
                    if @isVariableUsed stack, variable
                        @errors.push @astApi.createError
                            context:
                                name: variable
                            lineNumber: node.locationData.first_line + 1

            # Mark variable name as used.
            when node.variable?
                top[ node.variable.base.value ] = true

        # Recurse
        node.eachChild (child) => @lintNode child, stack.concat [{}]
