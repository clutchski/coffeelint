
module.exports = class NoDebugger

    rule:
        name: 'no_debugger'
        level : 'warn'
        message : 'Debugger statements will cause warnings'
        description: """
            This rule detects the `debugger` statement.
            This rule is `warn` by default.
            """

    tokens: [ "DEBUGGER" ]

    lintToken : (token, tokenApi) ->
        return {context : "found '#{token[0]}'"}
