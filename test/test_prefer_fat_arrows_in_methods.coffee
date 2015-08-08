path = require 'path'
vows = require 'vows'
assert = require 'assert'
{inspect} = require 'util'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'prefer_fat_arrows_in_methods'

runLint = (source) ->
    config = {}
    config[name] = level: 'ignore' for name, rule of coffeelint.RULES
    config[RULE].level = 'error'
    coffeelint.lint source, config

shouldError = (source, numErrors = 1) ->
    topic: source
    'errors for preferred arrow': (source) ->
        errors = runLint source
        assert.lengthOf errors, numErrors,
            "Expected #{numErrors} errors, got #{inspect errors}"
        error = errors[0]
        assert.equal error.rule, RULE

shouldPass = (source) ->
    topic: source
    'does not error for preferred arrows': (source) ->
        errors = runLint source
        assert.isEmpty errors, "Expected no errors, got #{inspect errors}"

vows.describe(RULE).addBatch({

    'empty function'            : shouldPass '->'
    'function without far arrow': shouldPass '-> ->'
    'function with far arrow'   : shouldPass '-> =>'

    'nested functions with this inside':
        'with inner fat arrow': shouldPass '-> =>'
        'with outer fat arrow': shouldPass '=> ->'
        'with both fat arrows': shouldPass '=> =>'

    'deeply nested functions':
        'with thin arrow'     : shouldPass '-> -> -> -> ->'
        'with fat arrow'      : shouldPass '-> -> -> -> =>'
        'with wrong fat arrow': shouldPass '-> -> => -> ->'

    'class instance method':
        'without fat arrow': shouldError """
            class A
                @m: -> ->
            """
        'with fat arrow': shouldPass """
            class A
                @m: -> =>
            """

    'class method':
        'without fat arrow': shouldError """
            class A
                m: -> ->
            """
        'with fat arrow': shouldPass """
            class A
                m: -> =>
            """

    'function in class body':
        'without fat arrow': shouldPass """
            class A
                f = -> ->
                x: 2
            """
        'with fat arrow': shouldPass """
            class A
                f = -> =>
                x: 2
            """

    'function inside class instance method':
        'with fat arrow': shouldPass """
            class A
                m: -> =>
            """
        'without fat arrow': shouldError """
            class A
                m: -> ->
            """

    'mixture of class methods and function in class body':
        'with fat arrow': shouldPass """
            class A
                f = -> ->
                m: -> =>
                @n: -> =>
                o: -> =>
                @p: -> =>
            """

        'without fat arrow': shouldError """
            class A
                f = -> ->
                m: -> ->
                @n: -> ->
                o: -> ->
                @p: -> ->
            """, 4

    'using prototype':
        'with fat arrow': shouldPass """
            class A

            A::f = -> =>
            """

        'without fat arrow': shouldError """
            class A

            A::f = -> ->
            """

}).export(module)
