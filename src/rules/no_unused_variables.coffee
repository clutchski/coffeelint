VariableScope = require './util/variable_scope.coffee'


class NoUnusedVariables

    rule:
        name: 'no_unused_variables'
        level: 'ignore'
        message: 'No unused variables'
        description: """
            Disallows variables that are assigned and never used
            """


    lintAST: (node, @astApi) ->
        @variableScope = new VariableScope
        @lintNode node
        @parseScope @variableScope.popScope()
        undefined


    lintNode: (node) ->
        if node.constructor.name is 'Assign'
            @findLiterals node.variable, @variableScope.assignVariable
            @lintNode node.value
        else if node.constructor.name is 'Code'
            @variableScope.pushScope()
            for param in node.params
                @findLiterals param, @variableScope.defineArgument
            @lintNode node.body
            @parseScope @variableScope.popScope()
        else if node.constructor.name is 'For'
            for field in ['name', 'index'] when node[field]
                @findLiterals node[field], @variableScope.assignVariable
            node.eachChild (child) => @lintNode child
        else if node.constructor.name is 'Value'
            @findLiterals node.base, @variableScope.useVariable
        else
            node.eachChild (child) => @lintNode child


    findLiterals: (node, fn) ->
        if node.constructor.name == 'Value'
            @findLiterals node.base, fn
        else if node.constructor.name == 'Literal'
            fn node.value, node.locationData.first_line + 1
        else
            node.eachChild (child) => @findLiterals child, fn


    parseScope: (scope) ->
        for name, {defined, type, used} of scope
            continue if type isnt 'local' or used
            @errors.push @astApi.createError {
                lineNumber: defined, context: "#{name} is unused"
            }


module.exports = NoUnusedVariables
