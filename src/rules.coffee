
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


    # I don't know of any legitimate reason to define duplicate keys in an
    # object. It seems to always be a mistake, it's also a syntax error in
    # strict mode.
    # See http://jslinterrors.com/duplicate-key-a/
    duplicate_key :
        level : ERROR
        message : 'Duplicate key defined in object or class'

    coffeescript_error :
        level : ERROR
        message : '' # The default coffeescript error is fine.
