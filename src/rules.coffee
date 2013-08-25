
# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'

# CoffeeLint's default rule configuration.
module.exports =

    cyclomatic_complexity :
        value : 10
        level : IGNORE
        message : 'The cyclomatic complexity is too damn high'

    empty_constructor_needs_parens :
        level : IGNORE
        message : 'Invoking a constructor without parens and without arguments'

    non_empty_constructor_needs_parens :
        level : IGNORE
        message : 'Invoking a constructor without parens and with arguments'



    coffeescript_error :
        level : ERROR
        message : '' # The default coffeescript error is fine.
