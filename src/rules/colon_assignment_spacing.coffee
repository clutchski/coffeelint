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

        leftSpacing = token[2].first_column - tokenApi.peek(-1)?[2].last_column
        leftAllowance = parseInt(spacingAllowances.left) + 1
        leftSpaced = leftSpacing is leftAllowance

        nextToken = tokenApi.peek(1)
        rightAllowance =
            if nextToken[0] is 'STRING'
                parseInt(spacingAllowances.right) + 1
            else
                parseInt(spacingAllowances.right)
        rightSpacing = nextToken[2]?.first_column - token[2].last_column
        rightSpaced = rightSpacing is rightAllowance

        if rightSpaced and leftSpaced
            null
        else
            context : "Expect colon spacing left: #{spacingAllowances.left}, right: #{spacingAllowances.right}." +
                " Got left: #{leftSpacing}, right: #{rightSpacing}."