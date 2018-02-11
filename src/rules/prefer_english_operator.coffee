module.exports = class PreferEnglishOperator

    rule:
        name: 'prefer_english_operator'
        level: 'ignore'
        message: 'Don\'t use &&, ||, ==, !=, or !'
        doubleNotLevel: 'ignore'
        ops: ['and', 'or', 'not', 'is', 'isnt']
        description: '''
            This rule prohibits &&, ||, ==, != and !.
            Use and, or, is, isnt, and not instead.
            !! for converting to a boolean is ignored.
            '''

    tokens: ['COMPARE', 'UNARY_MATH', '&&', '||']

    lintToken: (token, tokenApi) ->
        config = tokenApi.config[@rule.name]
        level = config.level

        # Compare the actual token with the lexed token.
        { first_column, last_column } = token[2]
        line = tokenApi.lines[tokenApi.lineNumber]
        actual_token = line[first_column..last_column]

        context =
            switch true
                when actual_token == '==' and 'is' in config.ops then 'Replace "==" with "is"'
                when actual_token == '!=' and 'isnt' in config.ops then 'Replace "!=" with "isnt"'
                when actual_token == '||' and 'or' in config.ops then 'Replace "||" with "or"'
                when actual_token == '&&' and 'and' in config.ops then 'Replace "&&" with "and"'
                when actual_token == '!' and 'not' in config.ops
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
            { token, level, context }
