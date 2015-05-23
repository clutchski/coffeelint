
module.exports = class NewlinesAfterClasses

    rule:
        name: 'newlines_after_classes'
        value : 3
        level : 'ignore'
        message : 'Wrong count of newlines between a class and other code'
        description: """
        <p>Checks the number of newlines between classes and other code.</p>
        
        Options:
        - <pre><code>value</code></pre> - The number of required newlines
        after class definitions. Defaults to 3.
        """

    lintLine: (line, lineApi) ->
        ending = lineApi.config[@rule.name].value

        return null if not ending or lineApi.isLastLine()

        { lineNumber, context } = lineApi
        if not context.class.inClass and
                context.class.lastUnemptyLineInClass? and
                (lineNumber - context.class.lastUnemptyLineInClass) isnt
                ending
            got = lineNumber - context.class.lastUnemptyLineInClass
            return  { context: "Expected #{ending} got #{got}" }

        null

