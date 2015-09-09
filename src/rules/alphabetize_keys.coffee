_ = require 'underscore'

module.exports = class AlphabetizeKeys

    rule:
        name: 'alphabetize_keys'
        level: 'ignore'
        message: 'Object keys should be alphabetized'
        description: 'Makes finding keys within an object very easy'

    tokens: [ 'IDENTIFIER', '{', '}' ]

    constructor: ->
        @braceScopes = []

    lintToken : ([type], tokenApi) ->
        switch type
            when '{', '}'
                @lintBrace arguments...
            when 'IDENTIFIER'
                @lintIdentifier arguments...

    lintIdentifier : (token, tokenApi) ->
        @currentScope?.push token[1]
        null

    lintBrace : (token) ->
        error = false

        if token[0] is '{'
            @braceScopes.push @currentScope if @currentScope?
            @currentScope = []
        else
            for key, index in @currentScope when index isnt 0
                if key < @currentScope[index - 1]
                    error = true
                    break
            @currentScope = @braceScopes.pop()

        error
