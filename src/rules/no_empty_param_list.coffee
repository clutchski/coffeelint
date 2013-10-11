

module.exports = class NoEmptyParamList

    rule:
        name: 'no_empty_param_list'
        level : 'ignore'
        message : 'Empty parameter list is forbidden'
        description: """
            This rule prohibits empty parameter lists in function definitions.
            <pre>
            <code># The empty parameter list in here is unnecessary:
            myFunction = () -&gt;

            # We might favor this instead:
            myFunction = -&gt;
            </code>
            </pre>
            Empty parameter lists are permitted by default.
            """

    tokens: [ "PARAM_START" ]

    lintToken : (token, tokenApi) ->
        nextType = tokenApi.peek()[0]
        return nextType is 'PARAM_END'

