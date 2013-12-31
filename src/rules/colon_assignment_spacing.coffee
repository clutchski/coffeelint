module.exports = class ColonAssignmentSpacing

    rule :
        name : 'colon_assignment_spacing'
        level : 'ignore'
        message :'Colon assignment without proper spacing'
        spacing :
            left : 0
            right : 0
        description : """
            <p>This rule checks to see that there is spacing before and
            after the colon in a colon assignment (i.e., classes, objects).
            The spacing amount is specified by
            spacing.left and spacing.right, respectively.
            A zero value means no spacing required.
            </p>
            <pre><code>
            #
            # If spacing.left and spacing.right is 1
            #

            # Good
            object = {spacing : true}
            class Dog
              canBark : true

            # Bad
            object = {spacing: true}
            class Cat
              canBark: false
            </code></pre>
            """

    tokens : [':']

    lintToken : (token, tokenApi) ->
        spacingAllowances = tokenApi.config[@rule.name].spacing
        previousToken = tokenApi.peek -1
        nextToken = tokenApi.peek 1

        getSpaceFromToken = (direction) ->
            switch direction
                when 'left'
                    token[2].first_column - previousToken[2].last_column - 1
                when 'right'
                    nextToken[2].first_column - token[2].first_column - 1

        checkSpacing = (direction) ->
            spacing = getSpaceFromToken direction
            # when spacing is negative, the neighboring token is a newline
            isSpaced = if spacing < 0 then true else spacing is parseInt spacingAllowances[direction]
            [isSpaced, spacing]

        [isLeftSpaced, leftSpacing] = checkSpacing 'left'
        [isRightSpaced, rightSpacing] = checkSpacing 'right'

        if isLeftSpaced and isRightSpaced
            null
        else
            context :
                """
                Incorrect spacing around column #{token[2].first_column}.
                Expected left: #{spacingAllowances.left}, right: #{spacingAllowances.right}.
                Got left: #{leftSpacing}, right: #{rightSpacing}.
                """