module.exports = class NoTabs

    rule:
        name: 'cyclomatic_complexity'
        value : 10
        level : 'ignore'
        message : 'The cyclomatic complexity is too damn high'
        description : 'Examine the complexity of your application.'

    # returns the "complexity" value of the current node.
    getComplexity : (node) ->
        name = node.constructor.name
        complexity = if name in ['If', 'While', 'For', 'Try']
            1
        else if name == 'Op' and node.operator in ['&&', '||']
            1
        else if name == 'Switch'
            node.cases.length
        else
            0
        return complexity

    lintAST : (node, @astApi) ->
        @lintNode node
        undefined

    # Lint the AST node and return its cyclomatic complexity.
    lintNode : (node, line) ->

        # Get the complexity of the current node.
        name = node.constructor.name
        complexity = @getComplexity(node)

        # Add the complexity of all child's nodes to this one.
        node.eachChild (childNode) =>
            nodeLine = childNode.locationData.first_line
            complexity += @lintNode(childNode, nodeLine) if childNode

        rule = @astApi.config[@rule.name]

        # If the current node is a function, and it's over our limit, add an
        # error to the list.
        if name == 'Code' and complexity >= rule.value
            error = @astApi.createError {
                context: complexity + 1
                lineNumber: line + 1
                lineNumberEnd: node.locationData.last_line + 1
            }
            @errors.push error if error

        # Return the complexity for the benefit of parent nodes.
        return complexity
