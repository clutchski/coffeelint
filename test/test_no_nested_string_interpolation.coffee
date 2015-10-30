path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_nested_string_interpolation'

vows.describe(RULE).addBatch({

    'Non-nested string interpolation':
        topic:
            '''
            "Book by #{firstName.toUpperCase()} #{lastName.toUpperCase()}"
            '''

        'is allowed': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Nested string interpolation':
        topic:
            '''
            str = "Book by #{"#{firstName} #{lastName}".toUpperCase()}"
            '''

        'should generate a warning': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, RULE)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.level, 'warn')
            assert.equal(error.message,
                'Nested string interpolation is forbidden')

        'can be permitted': (source) ->
            config = no_nested_string_interpolation: { level: 'ignore' }
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Deeply nested string interpolation':
        topic:
            '''
            str1 = "string #{"interpolation #{"inception"}"}"
            str2 = "going #{"in #{"even #{"deeper"}"}"}"
            str3 = "#{"multiple #{"warnings"}"} for #{"diff #{"nestings"}"}"
            '''

        'generates only one warning per string': (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.lengthOf(errors, 4)
            assert.equal(rule, RULE) for { rule } in errors
            assert.equal(errors[0].lineNumber, 1)
            assert.equal(errors[1].lineNumber, 2)
            assert.equal(errors[2].lineNumber, 3)
            assert.equal(errors[3].lineNumber, 3)

}).export(module)
