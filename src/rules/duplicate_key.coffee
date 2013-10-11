
module.exports = class DuplicateKey

    rule:
        # I don't know of any legitimate reason to define duplicate keys in an
        # object. It seems to always be a mistake, it's also a syntax error in
        # strict mode.
        # See http://jslinterrors.com/duplicate-key-a/
        name: 'duplicate_key'
        level: 'error'
        message: 'Duplicate key defined in object or class'
        description:
            "Prevents defining duplicate keys in object literals and classes"

    tokens: [ 'IDENTIFIER', "{","}" ]

    constructor: ->
        @braceScopes = []   # A stack tracking keys defined in nexted scopes.

    lintToken : ([type], tokenApi) ->

        if type in [ "{","}" ]
            @lintBrace arguments...
            return undefined

        if type is "IDENTIFIER"
            @lintIdentifier arguments...

    lintIdentifier : (token, tokenApi) ->
        key = token[1]

        # Class names might not be in a scope
        return null if not @currentScope?
        nextToken = tokenApi.peek(1)

        # Exit if this identifier isn't being assigned. A and B
        # are identifiers, but only A should be examined:
        # A = B
        return null if nextToken[1] isnt ':'
        previousToken = tokenApi.peek(-1)

        # Assigning "@something" and "something" are not the same thing
        key = "@#{key}" if previousToken[0] == '@'

        # Added a prefix to not interfere with things like "constructor".
        key = "identifier-#{key}"
        if @currentScope[key]
            return true
        else
            @currentScope[key] = token
            null

    lintBrace : (token) ->
        if token[0] == '{'
            @braceScopes.push @currentScope if @currentScope?
            @currentScope = {}
        else
            @currentScope = @braceScopes.pop()

        return null
