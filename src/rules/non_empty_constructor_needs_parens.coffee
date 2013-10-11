
ParentClass = require './empty_constructor_needs_parens.coffee'

module.exports = class NonEmptyConstructorNeedsParens extends ParentClass

    rule:
        name: 'non_empty_constructor_needs_parens'
        level: 'ignore'
        message: 'Invoking a constructor without parens and with arguments'
        description:
            "Requires constructors with parameters to include the parens"

    handleExpectedCallStart: (expectedCallStart) ->
        if expectedCallStart[0] is 'CALL_START' and expectedCallStart.generated
            return true
