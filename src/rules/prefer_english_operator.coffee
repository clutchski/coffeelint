module.exports = class RuleProcessor
    rule:
        name: 'prefer_english_operator'
        description: "TODO: write me"
        level: 'ignore'
        doubleNotLevel: 'ignore'
        message: 'Don\'t use &&, ||, ==, !=, or ! (or do!)'
        invert: false
    tokens: ['COMPARE', 'UNARY_MATH', 'LOGIC']
    lintToken: (token, tokenApi) ->
        config = tokenApi.config[@rule.name]
        level = config.level
        { first_column, last_column } = token[2]
        line = tokenApi.lines[tokenApi.lineNumber]
        actual_token = line[first_column..last_column]
        context =
            if config.invert is true
                switch actual_token
                    when 'is' then 'Replace "is" with "=="'
                    when 'isnt' then 'Replace "isnt" with "!="'
                    when 'or' then 'Replace "or" with "||"'
                    when 'and' then 'Replace "and" with "&&"'
                    when 'not' then 'Replace "not" with "!"'
            else if not config.invert
                switch actual_token
                  when '==' then 'Replace "==" with "is"'
                  when '!=' then 'Replace "!=" with "isnt"'
                  when '||' then 'Replace "||" with "or"'
                  when '&&' then 'Replace "&&" with "and"'
                  when '!'
                      if tokenApi.peek(1)?[0] is 'UNARY_MATH'
                          level = config.doubleNotLevel
                          '"?" is usually better than "!!"'
                      else if tokenApi.peek(-1)?[0] is 'UNARY_MATH'
                          undefined
                      else
                          'Replace "!" with "not"'
            else
                undefined

        if context?
            { level, context }
