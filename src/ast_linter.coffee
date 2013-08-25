BaseLinter = require './base_linter.coffee'

# A class that performs static analysis of the abstract
# syntax tree.
module.exports = class ASTLinter extends BaseLinter

    constructor : (source, config, rules, @CoffeeScript) ->
        super source, config, rules
        @errors = []

    # Custom rules are not yet supported in the ASTLinter. Maybe we don't need
    # them?
    acceptRule: (rule) ->
        false

    lint : () ->
        try
            @node = @CoffeeScript.nodes(@source)
        catch coffeeError
            @errors.push @_parseCoffeeScriptError(coffeeError)
            return @errors
        @lintNode(@node)
        @errors

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

    # Lint the AST node and return its cyclomatic complexity.
    lintNode : (node, line) ->

        # Get the complexity of the current node.
        name = node.constructor.name
        complexity = @getComplexity(node)

        # Add the complexity of all child's nodes to this one.
        node.eachChild (childNode) =>
            nodeLine = childNode.locationData.first_line
            complexity += @lintNode(childNode, nodeLine) if childNode

        # If the current node is a function, and it's over our limit, add an
        # error to the list.
        rule = @config.cyclomatic_complexity

        if name == 'Code' and complexity >= rule.value
            attrs = {
                context: complexity + 1
                level: rule.level
                lineNumber: line + 1
                lineNumberEnd: node.locationData.last_line + 1
            }
            error = @createError 'cyclomatic_complexity', attrs
            @errors.push error if error

        # Return the complexity for the benefit of parent nodes.
        return complexity

    _parseCoffeeScriptError : (coffeeError) ->
        rule = @config['coffeescript_error']

        message = coffeeError.toString()

        # Parse the line number
        lineNumber = -1
        if coffeeError.location?
            lineNumber = coffeeError.location.first_line + 1
        else
            match = /line (\d+)/.exec message
            lineNumber = parseInt match[1], 10 if match?.length > 1
        attrs = {
            message: message
            level: rule.level
            lineNumber: lineNumber
        }
        return  @createError 'coffeescript_error', attrs


