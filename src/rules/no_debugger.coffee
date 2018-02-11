module.exports = class NoDebugger

    rule:
        name: 'no_debugger'
        level: 'warn'
        message: 'Found debugging code'
        console: false
        description: '''
            This rule detects `debugger` and optionally `console` calls
            This rule is `warn` by default.
            '''

    # TODO: after <1.10.0 is not supported, remove 'DEBUGGER' here
    tokens: ['STATEMENT', 'DEBUGGER', 'IDENTIFIER']

    lintToken: (token, tokenApi) ->
        if token[0] in ['DEBUGGER', 'STATEMENT'] and token[1] is 'debugger'
            return { token, context: "found '#{token[0]}'" }

        if tokenApi.config[@rule.name]?.console
            if token[1] is 'console' and tokenApi.peek(1)?[0] is '.'
                method = tokenApi.peek(2)
                return { token, context: "found 'console.#{method[1]}'" }
