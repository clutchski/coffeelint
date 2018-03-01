module.exports = class ColonAssignmentSpacing
    rule:
        name: 'colon_assignment_spacing'
        level: 'ignore'
        message: 'Colon assignment without proper spacing'
        spacing:
            left: 0
            right: 0
            min_left: -1
            min_right: -1
        description: '''
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

            # Doesn't throw an error
            object = {spacing : true}
            class Dog
              canBark : true

            # Throws an error
            object = {spacing: true}
            class Cat
              canBark: false
            </code></pre>
            '''

    tokens: [':']

    lintToken: (token, tokenApi) ->
        spaceRules = tokenApi.config[@rule.name].spacing
        previousToken = tokenApi.peek -1
        nextToken = tokenApi.peek 1

        checkSpacing = (direction) ->
            spacing = switch direction
                when 'left'
                    token[2].first_column - previousToken[2].last_column - 1
                else # when 'right'
                    nextToken[2].first_column - token[2].first_column - 1

            # when spacing is negative, the neighboring token is a newline
            if spacing < 0
                true
            else
                minDirection = parseInt spaceRules['min_' + direction]
                # if a minimal spacing is specified, only check that
                if minDirection >= 0
                    spacing >= minDirection
                # otherwise check exact spacing
                else
                    spacing is parseInt spaceRules[direction]

        if (checkSpacing 'left') and (checkSpacing 'right')
            null
        else
            context: "Incorrect spacing around column #{token[2].first_column}"
