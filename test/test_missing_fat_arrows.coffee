path = require 'path'
vows = require 'vows'
assert = require 'assert'
{inspect} = require 'util'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'missing_fat_arrows'

runLint = (source) ->
    config = {}
    config[name] = level: 'ignore' for name, rule of coffeelint.RULES
    config[RULE].level = 'error'
    coffeelint.lint source, config

shouldError = (source, numErrors = 1) ->
    topic: source
    'errors for missing arrow': (source) ->
        errors = runLint source
        assert.lengthOf errors, numErrors,
            "Expected #{numErrors} errors, got #{inspect errors}"
        error = errors[0]
        assert.equal error.rule, RULE

shouldPass = (source) ->
    topic: source
    'does not error for no missing arrows': (source) ->
        errors = runLint source
        assert.isEmpty errors, "Expected no errors, got #{inspect errors}"

vows.describe(RULE).addBatch({

    'empty function'        : shouldPass '->'
    'function without this' : shouldPass '-> 1'
    'function with this'    : shouldError '-> this'
    'function with this.a'  : shouldError '-> this.a'
    'function with @'       : shouldError '-> @'
    'function with @a'      : shouldError '-> @a'

    'nested functions with this inside':
        'with inner fat arrow': shouldPass '-> => this'
        'with outer fat arrow': shouldError '=> -> this'
        'with both fat arrows': shouldPass '=> => this'

    'nested functions with this outside':
        'with inner fat arrow': shouldError '-> (this; =>)'
        'with outer fat arrow': shouldPass '=> (this; ->)'
        'with both fat arrows': shouldPass '=> (this; =>)'

    'deeply nested functions':
        'with thin arrow'     : shouldError '-> -> -> -> -> this'
        'with fat arrow'      : shouldPass '-> -> -> -> => this'
        'with wrong fat arrow': shouldError '-> -> => -> -> this'

    'functions with multiple statements' : shouldError """
        f = ->
            this.x = 2
            z ((a) -> a; this.x)
        """, 2

    'class instance method':
        'without this': shouldPass """
            class A
                @m: -> 1
            """
        'with this': shouldPass """
            class A
                @m: -> this
            """

    'class method':
        'without this': shouldPass """
            class A
                m: -> 1
            """
        'with this': shouldPass """
            class A
                m: -> this
            """

    'function in class body':
        'without this': shouldPass """
            class A
                f = -> 1
                x: 2
            """
        'with this': shouldError """
            class A
                f = -> this
                x: 2
            """

    'function inside class instance method':
        'without this': shouldPass """
            class A
                m: -> -> 1
            """
        'with this': shouldError """
            class A
                m: -> -> @a
            """

    'mixture of class methods and function in class body':
        'with this': shouldPass """
            class A
                f = => this
                m: -> this
                @n: -> this
                o: -> this
                @p: -> this
            """

}).export(module)
