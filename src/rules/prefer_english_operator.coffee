
module.exports = class PreferEnglishOperator
    rule:
        name: 'prefer_english_operator'
        description: '''
        This rule prohibits &&, ||, ==, != and !.
        Use and, or, is, isnt, and not instead.
        !! for converting to a boolean is ignored.
        '''
        level: 'ignore'
        doubleNotLevel: 'ignore'
        message: 'Don\'t use &&, ||, ==, !=, or !'

    tokens: ['COMPARE', 'UNARY_MATH', 'LOGIC']
    lintToken: (token, tokenApi) ->
        config = tokenApi.config[@rule.name]
        level = config.level
        # Compare the actual token with the lexed token.
        { first_column, last_column } = token[2]
        line = tokenApi.lines[tokenApi.lineNumber]
        actual_token = line[first_column..last_column]
        context =
            switch actual_token
                when '==' then 'Replace "==" with "is"'
                when '!=' then 'Replace "!=" with "isnt"'
                when '||' then 'Replace "||" with "or"'
                when '&&' then 'Replace "&&" with "and"'
                when '!'
                    # `not not expression` seems awkward, so `!!expression`
                    # gets special handling.
                    if tokenApi.peek(1)?[0] is 'UNARY_MATH'
                        level = config.doubleNotLevel
                        '"?" is usually better than "!!"'
                    else if tokenApi.peek(-1)?[0] is 'UNARY_MATH'
                        # Ignore the 2nd half of the double not
                        undefined
                    else
                        'Replace "!" with "not"'
                else undefined

        if context?
            { level, context }
