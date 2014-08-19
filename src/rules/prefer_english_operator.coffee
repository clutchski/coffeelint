
module.exports = class RuleProcessor
    rule:
        name: 'prefer_english_operator'
        description: '''
        This rule prohibits &&, ||, ==, != and !.
        Use and, or, is, isnt, and not instead.
        !! for converting to a boolean is ignored.
        '''
        level: 'ignore'
        message: 'Don\'t use &&, ||, ==, !=, or !'

    tokens: ['COMPARE', 'UNARY_MATH', 'LOGIC']
    lintToken: (token, tokenApi) ->
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
                    # I think !!something is acceptable for coorcing a variable
                    # into a boolean. The alternative seems very awkward
                    # `not not something`?
                    if tokenApi.peek(1)?[0] isnt 'UNARY_MATH' and
                            tokenApi.peek(-1)?[0] isnt 'UNARY_MATH'
                        'Replace "!" with "not"'
                else undefined

        if context?
            { context }
