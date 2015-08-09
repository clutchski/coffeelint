path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('spacing').addBatch({

    'No spaces around binary operators' :

        topic : ->
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

        'are permitted by default' : (source) ->
            config = {no_nested_string_interpolation : {level:'ignore'}}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {
                space_operators                : {level:'error'},
                no_nested_string_interpolation : {level:'ignore'}
            }
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, source.split("\n").length)
            error = errors[0]
            assert.equal(error.rule, 'space_operators')
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, "Operators must be spaced properly")

    'Correctly spaced operators' :

        topic : ->
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

        'are permitted' : (source) ->
            config = {
                space_operators                : {level:'error'},
                no_nested_string_interpolation : {level:'ignore'}
            }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Spaces around unary operators' :

        topic : ->
            '''
            + 1
            - - 1
            '''

        'are permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {
                space_operators                : {level:'error'},
                no_nested_string_interpolation : {level:'ignore'}
            }
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 2)

    'No spaces around default parameters' :

        'are permitted by default' : ->
            errors = coffeelint.lint('foo = (bar={}) ->')
            assert.isEmpty(errors)
            errors = coffeelint.lint('foo = (bar = {}) ->')
            assert.isEmpty(errors)

        'can be forbidden' : ->
            config = {space_operators : {level:'error'}}
            errors = coffeelint.lint('foo = (bar={}) ->', config)
            assert.lengthOf(errors, 1)
            errors = coffeelint.lint('foo = (bar = {}) ->', config)
            assert.isEmpty(errors)

        'but also required through an option' : ->
            config = {space_operators : {
                level:'error', default_parameters:false
            }}
            # We do not do anything about things like:
            #   foo = (bar=(a=1))
            # There is little reason to use such code. So this will not
            # warn even if it should.
            errors = coffeelint.lint('foo = (bar={}) ->', config)
            assert.isEmpty(errors)
            errors = coffeelint.lint('foo = (bar ={}) ->', config)
            assert.lengthOf(errors, 1)
            errors = coffeelint.lint('foo = (bar = {}) ->', config)
            assert.lengthOf(errors, 1)
            errors = coffeelint.lint('foo = (bar= {}) ->', config)
            assert.lengthOf(errors, 1)
            errors = coffeelint.lint('foo = ({bar}={bar: 42}) ->', config)
            assert.isEmpty(errors)
            errors = coffeelint.lint('foo = ({bar} ={bar: 42}) ->', config)
            assert.lengthOf(errors, 1)
            errors = coffeelint.lint('foo = ({bar} = {bar: 42}) ->', config)
            assert.lengthOf(errors, 1)
            errors = coffeelint.lint('foo = ({bar}= {bar: 42}) ->', config)
            assert.lengthOf(errors, 1)

}).export(module)
