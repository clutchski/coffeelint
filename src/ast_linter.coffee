BaseLinter = require './base_linter.coffee'

node_children =
  Class:    ['variable', 'parent', 'body']
  Code:     ['params', 'body']
  For:      ['body', 'source', 'guard', 'step']
  If:       ['condition', 'body', 'elseBody']
  Obj:      ['properties']
  Op:       ['first', 'second']
  Switch:   ['subject', 'cases', 'otherwise']
  Try:      ['attempt', 'recovery', 'ensure']
  Value:    ['base', 'properties']
  While:    ['condition', 'guard', 'body']

hasChildren = (node, children) ->
    node?.children?.length is children.length and
    node?.children.every (elem, i) -> elem is children[i]

class ASTApi
    constructor: (@config) ->
    getNodeName: (node) ->
        name = node?.constructor?.name
        if node_children[name]
            return name
        else
            for own name, children of node_children
                if hasChildren(node, children)
                    return name


# A class that performs static analysis of the abstract
# syntax tree.
module.exports = class ASTLinter extends BaseLinter

    constructor : (source, config, rules, @CoffeeScript) ->
        super source, config, rules
        @astApi = new ASTApi @config

    # This uses lintAST instead of lintNode because I think it makes it a bit
    # more clear that the rule needs to walk the AST on its own.
    acceptRule: (rule) ->
        return typeof rule.lintAST is 'function'

    lint : () ->
        errors = []
        try
            @node = @CoffeeScript.nodes(@source)
        catch coffeeError
            # If for some reason you shut off the 'coffeescript_error' rule err
            # will be null and should NOT be added to errors
            err = @_parseCoffeeScriptError(coffeeError)
            errors.push err if err?
            return errors

        for rule in @rules
            @astApi.createError = (attrs = {}) =>
                @createError rule.rule.name, attrs

            # HACK: Push the local errors object into the plugin. This is a
            # temporary solution until I have a way for it to really return
            # multiple errors.
            rule.errors = errors
            v = @normalizeResult rule, rule.lintAST(@node, @astApi)

            return v if v?
        errors

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


