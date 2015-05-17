
module.exports = class NoThis
    rule:
        name: 'no_this'
        description: '''
        This rule prohibits 'this'.
        Use '@' instead.
        '''
        level: 'ignore'
        message: "Don't use 'this', use '@' instead"

    tokens: ['THIS']
    lintToken: (token, tokenApi) ->
        true
