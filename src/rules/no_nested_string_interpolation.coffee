module.exports = class NoNestedStringInterpolation

    rule:
        name: 'no_nested_string_interpolation'
        level: 'warn'
        message: 'Nested string interpolation is forbidden'
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

    tokens: ['CSX_TAG', 'CALL_START', 'CALL_END', 'STRING_START', 'STRING_END']

    constructor: ->
        @blocks = []

    lintToken: (token, tokenApi) ->
        [tag] = token
        @blocks.push [] unless @blocks.length

        block = @blocks[@blocks.length - 1]

        if tag is 'CSX_TAG'
            @blocks.push []
            return

        [tagname, tagtype] = tag.split '_'
        if tagtype == 'END'
            block.pop()
            if tagname is 'STRING'
                block.strCount -= 1
                block.error = false if block.strCount <= 1
            else
                @blocks.pop()
            if not block.length
                @blocks.pop()
            @blocks.push [] unless @blocks.length
        else
            block.push tagname
            if tagname is 'STRING'
                block.strCount = (block.strCount ? 0) + 1
                # Don't make multiple errors for deeply nested interpolation
                if block.strCount > 1 and not block.error
                    block.error = true
                    return { token }
        return
