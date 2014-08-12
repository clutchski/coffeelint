path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('indent').addBatch({

    'Indentation' :

        topic : () ->
            """
            x = () ->
              'two spaces'

            a = () ->
                'four spaces'
            """

        'defaults to two spaces' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]
            msg = 'Line contains inconsistent indentation'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 5)
            assert.equal(error.context, "Expected 2 got 4")

        'can be overridden' : (source) ->
            config =
                indentation:
                    level: 'error'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 2)

        'is optional' : (source) ->
            config =
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

    'Nested indentation errors' :

        topic : () ->
            """
            x = () ->
              y = () ->
                  1234
            """

        'are caught' : (source) ->
            errors = coffeelint.lint(source)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 3)

    'Compiler generated indentation' :

        topic : () ->
            """
            () ->
                if 1 then 2 else 3
            """

        'is ignored when not using two spaces' : (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Indentation inside interpolation' :

        topic : 'a = "#{ 1234 }"'

        'is ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indentation in multi-line expressions' :

        topic : """
        x = '1234' + '1234' + '1234' +
                '1234' + '1234'
        """

        'is ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indentation across line breaks' :

        topic : () ->
            """
            days = ["mon", "tues", "wed",
                       "thurs", "fri"
                                "sat", "sun"]

            x = myReallyLongFunctionName =
                    1234

            arr = [() ->
                    1234
            ]
            """

        'is ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indentation on seperate line invocation' :

        topic : """
            rockinRockin
                    .around ->
                      3

            rockrockrock.
                    around ->
                      1234
            """

        'is ignored. Issue #4' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Consecutive indented chained invocations' :

        topic : """
            $('body')
                .addClass('k')
                .removeClass 'k'
                .animate()
                .hide()
            """

        'is permitted' : (source) ->
            assert.isEmpty(coffeelint.lint(source))

    'Consecutive indented chained invocations and multi-line expression' :

        topic : """
            $('body')
              .addClass ->
                return $(this).name + $(this).that +
                  $(this).this
              .removeClass 'k'
            """

        'is permitted' : (source) ->
            assert.isEmpty(coffeelint.lint(source))

    'Consecutive indented chained invocations with bad indents' :
        topic : """
            $('body')
              .addClass('k')
                 # bad indented comments are ignored
              .removeClass 'k'
              # comments are ignored in checking, so are blank lines

              .animate()
                # comments are ignored
                 .hide() # this will check with '.animated()' and complain

            """
        'fails with indent error': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]

            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 9)
            assert.equal(error.context, "Expected 2 got 3")

    'One chain invocations with bad indents' :
        topic : """
            $('body')
               .addClass('k')
            """
        'fails with indent error': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]

            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 2)
            assert.equal(error.context, "Expected 2 got 3")

    'Separate chained invocations with bad indents' :
        topic : """
            $('body')
              .addClass ->
                return name + that +
                  there
               .removeClass 'k'

            $('html')
               .hello()
            """

        'correctly identifies two errors': (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 2)
            error = errors[0]

            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 5)
            assert.equal(error.context, "Expected 2 got 1")

            error = errors[1]

            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 8)
            assert.equal(error.context, "Expected 2 got 3")


    'Ignore comment in indented chained invocations' :
        topic : () ->
            """
            test()
                .r((s) ->
                    # Ignore this comment
                    # Ignore this one too
                    # Ignore this one three
                    ab()
                    x()
                    y()
                )
                .s()
            """
        'no error when comment is in first line of a chain' : (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Ignore blank line in indented chained invocations' :
        topic : () ->
            """
            test()
                .r((s) ->


                    ab()
                    x()
                    y()
                )
                .s()
            """
        'no error when blank line is in first line of a chain' : (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Arbitrarily indented arguments' :

        topic : """
            myReallyLongFunction withLots,
                                 ofArguments,
                                 everywhere
            """

        'are permitted' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indenting a callback in a chained call inside a function' :
        topic : """
            someFunction = ->
              $.when(somePromise)
                .done (result) ->
                  foo = result.bar
            """
        'is permitted. See issue #88': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Handle multiple chained calls' :
        topic : """
            anObject
              .firstChain (f) ->
                doStepOne()
                doAnotherStep()
                prepSomethingElse()
              .secondChain (s) ->
                moreStuff()
                return s
            """
        'is permitted': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Handle multiple chained calls (4 spaces)' :
        topic : """
            anObject
                .firstChain (f) ->
                    doStepOne()
                    doAnotherStep()
                    prepSomethingElse()
                .secondChain (s) ->
                    moreStuff()
                    return s
            """
        'fails when using 2 space indentation default': (source) ->
            msg = 'Line contains inconsistent indentation'

            errors = coffeelint.lint(source)
            assert.equal(errors.length, 2)
            error = errors[0]

            assert.equal(error.message, msg)
            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 3)
            assert.equal(error.context, "Expected 2 got 4")

            error = errors[1]

            assert.equal(error.message, msg)
            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 7)
            assert.equal(error.context, "Expected 2 got 4")

        'is permitted when changing configuration to use 4 spaces': (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Handle multiple chained calls inside more indentation' :
        topic : """
            someLongFunction = (a, b, c, d) ->
              retValue = anObject
                .firstChain (f) ->
                  doStepOne()
                  doAnotherStep()
                  prepSomethingElse()
                .secondChain (s) ->
                  moreStuff()
                  return s

              retValue + [1]

            """
        'is permitted': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Handle chains where there are tokens with generated property' :
        topic : """
            anObject 'bar'
              .firstChain ->
                doStepOne()
                doStepTwo()
              .secondChain ->
                a = b
                secondObject
                  .then ->
                    e ->
                  .finally x
            """
        'is permitted': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Handle nested chain calls' :
        topic : """
            anObject
              .firstChain (f) ->
                doStepOne()
                  .doAnotherStep()
                  .prepSomethingElse()
              .secondChain (s) ->
                moreStuff()
                return s
            """
        'is permitted': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)
    'Make sure indentation check is not affected outside proper scope' :
        topic : """
            a
              .b

            c = ->
              return d + e

            ->
              if a is c and
                (false or
                  long.expression.that.necessitates(linebreak))
                @foo()
            """
        'returns no errors outside scope': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Ignore dots in comments':
        topic: '''
        try
          # comment with dot at the end.
          true
        catch error
        '''

        ###
        # This is broken but because its an edge case I don't want to put it
        # into the test until its fixed.
        try
          foo # something.
          true
        catch error
        ###


        'returns no errors outside scope': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

}).export(module)
