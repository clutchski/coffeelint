
regexes =
    camelCase : /^[A-Z][a-zA-Z\d]*$/

module.exports = class CamelCaseClasses

    rule:
        name: 'camel_case_classes'
        level : 'error'
        message : 'Class names should be camel cased'
        description: """
            This rule mandates that all class names are CamelCased. Camel
            casing class names is a generally accepted way of distinguishing
            constructor functions - which require the 'new' prefix to behave
            properly - from plain old functions.
            <pre>
            <code># Good!
            class BoaConstrictor

            # Bad!
            class boaConstrictor
            </code>
            </pre>
            This rule is enabled by default.
            """

    tokens: [ 'CLASS' ]

    lintToken: (token, tokenApi) ->
        # TODO: you can do some crazy shit in CoffeeScript, like
        # class func().ClassName. Don't allow that.

        # Don't try to lint the names of anonymous classes.
        if token.newLine? or tokenApi.peek()[0] in ['INDENT', 'EXTENDS']
            return null

        # It's common to assign a class to a global namespace, e.g.
        # exports.MyClassName, so loop through the next tokens until
        # we find the real identifier.
        className = null
        offset = 1
        until className
            if tokenApi.peek(offset + 1)?[0] == '.'
                offset += 2
            else if tokenApi.peek(offset)?[0] == '@'
                offset += 1
            else
                className = tokenApi.peek(offset)[1]

        # Now check for the error.
        if not regexes.camelCase.test(className)
            return {context: "class name: #{className}"}
