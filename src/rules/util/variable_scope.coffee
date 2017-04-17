class VariableScope

    GLOBAL_VARIABLES = ['exports', 'global', 'module', 'this', 'window']

    constructor: ->
        @stack = [{}]


    # Returns the current scope
    currentScope: ->
        @stack[@stack.length - 1]


    # Pushs a new variable scope
    pushScope: ->
        @stack.push {}


    # Pops the current scope
    # returning the variables defined in the previous scope
    popScope: ->
        @stack.pop()


    # Define an argument
    defineArgument: (name, lineNumber) =>
        @currentScope()[name] =
            defined: lineNumber
            shadowing: @getVariable(name)
            type: 'argument'
            used: no


    # Assign a value to a variable
    assignVariable: (name, lineNumber) =>
        return if name in GLOBAL_VARIABLES
        variable = @getVariable name
        if variable
            variable.used = yes if variable.type is 'argument'
        else
            @currentScope()[name] =
                defined: lineNumber
                type: 'local'
                used: no


    # Returns the variable if already defined
    getVariable: (name) ->
        for i in [@stack.length - 1..0]
            variable = @stack[i][name]
            if variable? then return variable


    # Use a variable in some expression
    useVariable: (name, lineNumber) =>
        @getVariable(name)?.used = yes


module.exports = VariableScope
