
# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'

# CoffeeLint's default rule configuration.
module.exports =

    coffeescript_error :
        level : ERROR
        message : '' # The default coffeescript error is fine.
