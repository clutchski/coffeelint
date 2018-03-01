module.exports = class ParseintRadix

    rule:
        name: 'missing_parseint_radix'
        level : 'warn'
        message : 'parseInt is missing the radix argument'
        description: """
            This rule warns about using parseInt without a radix. From the MDN
            developers reference: <q>Always specify this parameter to eliminate
            reader confusion and to guarantee predictable behavior.</q>
            <pre>
              <code># You would expect this to result in 8, but
              # it might result in 0 (parsed as octal).
              parseInt '08'

              # To be safe, specify the radix argument:
              parseInt '08', 10
              </code>
            </pre>
            """


    tokens: ['CALL_START']

    lintToken : (token, tokenApi) ->
        [prevToken, functionName] = tokenApi.peek(-1)

        if functionName is 'parseInt'
            [callEnd] = tokenApi.peek(2)
            return callEnd is 'CALL_END'
