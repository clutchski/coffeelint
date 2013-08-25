
module.exports = class NoPlusPlus

    rule:
        name: 'no_plusplus'
        level : 'ignore'
        message : 'The increment and decrement operators are forbidden'
        description: """
            This rule forbids the increment and decrement arithmetic operators.
            Some people believe the <tt>++</tt> and <tt>--</tt> to be cryptic
            and the cause of bugs due to misunderstandings of their precedence
            rules.
            This rule is disabled by default.
            """

    tokens: [ "++", "--" ]

    lintToken : (token, tokenApi) ->
        return {context : "found '#{token[0]}'"}
