
module.exports = class NoNestedStringInterpolation

    rule:
        name: 'no_nested_string_interpolation'
        level : 'warn'
        message : 'Nested string interpolation is forbidden'
        description: '''
            This rule warns about nested string interpolation,
            as it tends to make code harder to read and understand.
            <pre>
            <code># Good!
            str = "Book by #{firstName.toUpperCase()} #{lastName.toUpperCase()}"

            # Bad!
            str = "Book by #{"#{firstName} #{lastName}".toUpperCase()}"
            </code>
            </pre>
            '''

    tokens: [ 'STRING_START', 'STRING_END' ]

    constructor: ->
        @startedStrings = 0
        @generatedError = false

    lintToken: ([type], tokenApi) ->
        if type is 'STRING_START'
            @trackStringStart()
        else
            @trackStringEnd()

    trackStringStart: ->
        @startedStrings += 1

        # Don't generate multiple errors for deeply nested string interpolation
        return if @startedStrings <= 1 or @generatedError

        @generatedError = true
        return true

    trackStringEnd: ->
        @startedStrings -= 1
        @generatedError = false if @startedStrings is 1
