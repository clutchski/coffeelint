path = require 'path'
vows = require 'vows'
assert = require 'assert'
{inspect} = require 'util'
coffeelint = require path.join('..', 'src', 'coffeelint')

isUnused = (err, name) ->
    assert err?, "Expected error for #{name}"
    assert.isTrue err.message is 'Unused variable',
        "Expected: Unused variable " +
        "Actual: #{err.message}"

    # Why does VowsJS require me to reinvent an assertion just to be able to
    # read the result?
    assert.isTrue err.context is name,
        "Expected: #{name} " +
        "Actual: #{err.context}"

isUndefined = (err, name) ->
    assert err?, "Expected error for #{name}"
    assert.isTrue err.message is 'Undefined variable',
        "Expected: Undefined variable " +
        "Actual: #{err.message}"

    assert.isTrue err.context is name,
        "Expected: #{name} " +
        "Actual: #{err.context}"

# When multiple errors occur on the same line they come back in a
# non-deterministic order. This doesn't generally matter except the code is
# easier to read here if the order is known. This will re-sort so that errors
# on the same line are in alphabetical order.
errorSorter = (a, b) ->
    if a.lineNumber < b.lineNumber
        -1
    else if a.lineNumber > b.lineNumber
        1
    else
        if a.context < b.context
            -1
        else if a.context > b.context
            1
        else
            0

RULE = 'undefined_variables'

runLint = (source) ->
    config = {}
    config[name] = level: 'ignore' for name of coffeelint.RULES
    config[RULE].level = 'error'

    config[RULE].globals = [ 'noop' ]
    coffeelint.lint source, config

shouldError = (mode, source, variables) ->
    spec =
        topic: source

    spec["errors for #{mode} variables"] = (source) ->
        numErrors = variables.length
        errors = runLint source

        assert.lengthOf errors, numErrors,
            "Expected #{numErrors} errors, got #{inspect errors}"

        error = errors[0]
        assert.equal error.rule, RULE
    spec

shouldPass = (source) ->
    topic: source
    'does not error for no undefined/unused variables': (source) ->
        errors = runLint source
        assert.isEmpty errors, "Expected no errors, got #{inspect errors}"

vows.describe(RULE).addBatch({

    'Undefined Variables':

        'assigning with an undefined index':  shouldError 'undefined', '''
            obj = {}
            obj.foo = 'foo'
            obj[missingIndex] = 'foo'
        ''', [ 'missingIndex' ]

        'call function with undefined param': shouldError 'undefined', '''
            fn = ->
            fn(param)
        ''', [ 'param' ]

        'call function on undefined': shouldError 'undefined', '''
            instance.something()
        ''', [ 'instance' ]

        'undefined class parameter': shouldError 'undefined', '''
            new Error param
        ''', [ 'param' ]

        'bad index in a function call': shouldError 'undefined', '''
            noop = -> undefined
            param = {}
            noop param[badIndex]
        ''', [ 'badIndex' ]

    'Unused Variables' :

        'Loop with condition': shouldPass '''
            foo = {}
            for key, value of foo when value?
                noop key

        '''

        'variables in switch subject and cases are used': shouldPass '''
            switchSubject = 2
            switchCase = 3
            switch 1 + switchSubject
                when switchCase
                    return
        '''

        topic :
            """
            noop = -> undefined

            ###
            # global someGlobal
            ###

            unusedFunction = -> undefined

            class ParentClass

            class UnusedClass extends ParentClass

              foo: (a, b, extraParam) ->
                noop b

              bar: (x, y, z) ->
                undefined

            { foo: destructuredObject } = noop

            { outer : { inner: deepDestructuredObject  } } = noop

            [ destructuredArray ] = noop
            [ [ deepDestructuredArray ] ] = noop

            for objIndex, objValue of {}
              undefined

            # Similar to parameters using objValue2 prevents an unused variable
            # error on objIndex2.
            for objIndex2, objValue2 of {}
              noop objValue2

            for arrValue, arrIndex of []
              undefined

            for arrValue2, arrIndex2 of []
              noop arrIndex2

            splatFn = (splat...) -> undefined

            destructuringFn = ([destructuredParameter]) -> undefined

            # lastParam is NOT unused, but it was being wrongly counted as
            # unused.
            lastParam = undefined
            noop { lp: lastParam }
            window.foo = { lp: lastParam }

            cache = undefined
            window.getCache = ->
              cache ?= Math.random()

            """

        'unused variables' : (source) ->
            return

            errors = coffeelint.lint source,
                {undefined_variables: {'level':'error'}}

            errors.sort errorSorter

            isUnused errors.shift(), 'unusedFunction'
            isUnused errors.shift(), 'UnusedClass'

            # Because variable b is used in the function a is considered to
            # have been used since it's no longer optional.
            isUnused errors.shift(), 'extraParam'

            isUnused errors.shift(), 'x'
            isUnused errors.shift(), 'y'
            isUnused errors.shift(), 'z'

            isUnused errors.shift(), 'destructuredObject'
            isUnused errors.shift(), 'deepDestructuredObject'
            isUnused errors.shift(), 'destructuredArray'
            isUnused errors.shift(), 'deepDestructuredArray'

            isUnused errors.shift(), 'objIndex'
            isUnused errors.shift(), 'objValue'

            isUnused errors.shift(), 'arrIndex'
            isUnused errors.shift(), 'arrValue'

            isUnused errors.shift(), 'splat'
            isUnused errors.shift(), 'splatFn'

            # isUnused errors.shift(), 'destructuredParameter'
            isUnused errors.shift(), 'destructuringFn'

            assert.isEmpty(errors)

}).export(module)
