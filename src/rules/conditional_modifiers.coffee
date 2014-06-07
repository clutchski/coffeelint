
module.exports = class ConditionalModifiers

    rule:
        name: 'conditional_modifiers'
        level : 'ignore'
        message : 'Conditional modifiers are forbidden'
        description: """
            This rule forbids the use of conditional modifiers (lines that end
            with conditionals).
            Some people believe conditional modifiers make code harder to read.
            This rule is disabled by default.
            """

    tokens: [ "POST_IF" ]

    lintToken : (token, tokenApi) ->
        return {context : "found '#{token[0]}'"}
