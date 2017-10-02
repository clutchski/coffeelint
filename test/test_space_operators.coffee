path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'space_operators'

vows.describe(RULE).addBatch({

    'No spaces around binary operators':
        topic:
            '''
            x= 1
            1+ 1
            1- 1
            1/ 1
            1* 1
            1== 1
            1>= 1
            1> 1
            1< 1
            1<= 1
            1% 1
            (a= 'b') -> a
            a| b
            a& b
            a*= -5
            a*= -b
            a*= 5
            a*= a
            -a+= -2
            -a+= -a
            -a+= 2
            -a+= a
            a* -b
            a** b
            a// b
            a%% b
            x =1
            1 +1
            1 -1
            1 /1
            1 *1
            1 ==1
            1 >=1
            1 >1
            1 <1
            1 <=1
            1 %1
            (a ='b') -> a
            a |b
            a &b
            a *=-5
            a *=-b
            a *=5
            a *=a
            -a +=-2
            -a +=-a
            -a +=2
            -a +=a
            a *-b
            a **b
            a //b
            a %%b
            x=1
            1+1
            1-1
            1/1
            1*1
            1==1
            1>=1
            1>1
            1<1
            1<=1
            1%1
            (a='b') -> a
            a|b
            a&b
            a*=-5
            a*=-b
            a*=5
            a*=a
            -a+=-2
            -a+=-a
            -a+=2
            -a+=a
            a*-b
            a**b
            a//b
            a%%b
            '''

        'are permitted by default': (source) ->
            config = { no_nested_string_interpolation: { level: 'ignore' } }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

        'can be forbidden': (source) ->
            config =
                space_operators: { level: 'error' },
                no_nested_string_interpolation: { level: 'ignore' }

            errors = coffeelint.lint(source, config)
            sources = source.split('\n')

            assert.equal(err.line, sources[i]) for err, i in errors
            assert.equal(errors.length, sources.length)

            error = errors[0]
            assert.equal(error.rule, RULE)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Operators must be spaced properly')

    'Correctly spaced operators':
        topic:
            '''
            x = 1
            1 + 1
            1 - 1
            1 / 1
            1 * 1
            1 == 1
            1 >= 1
            1 > 1
            1 < 1
            1 <= 1
            (a = 'b') -> a
            +1
            -1
            y = -2
            x = -1
            y = x++
            x = y++
            1 + (-1)
            -1 + 1
            x(-1)
            x(-1, 1, -1)
            x[..-1]
            x[-1..]
            x[-1...-1]
            1 < -1
            a if -1
            a unless -1
            a if -1 and 1
            a if -1 or 1
            1 and -1
            1 or -1
            "#{a}#{b}"
            "#{"#{a}"}#{b}"
            [+1, -1]
            [-1, +1]
            {a: -1}
            /// #{a} ///
            if -1 then -1 else -1
            a | b
            a & b
            a *= 5
            a *= -5
            a *= b
            a *= -b
            -a *= 5
            -a *= -5
            -a *= b
            -a *= -b
            a * -b
            a ** b
            a // b
            a %% b
            return -1
            for x in xs by -1 then x

            switch x
              when -1 then 42
            '''

        'are permitted': (source) ->
            config =
                space_operators: { level: 'error' },
                no_nested_string_interpolation: { level: 'ignore' }

            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Spaces around unary operators':
        topic:
            '''
            + 1
            - - 1
            '''

        'are permitted by default': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

        'can be forbidden': (source) ->
            config =
                space_operators: { level: 'error' },
                no_nested_string_interpolation: { level: 'ignore' }

            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 2)
            assert.equal(rule, RULE) for { rule } in errors

}).export(module)
