
module.exports = class NoStandAloneAt

    rule:
        name: 'no_stand_alone_at'
        level : 'ignore'
        message : '@ must not be used stand alone'
        description: """
            This rule checks that no stand alone @ are in use, they are
            discouraged. Further information in CoffeScript issue <a
            href="https://github.com/jashkenas/coffee-script/issues/1601">
            #1601</a>
            """


    tokens: [ "@" ]

    lintToken : (token, tokenApi) ->
        nextToken = tokenApi.peek()
        spaced = token.spaced
        isIdentifier = nextToken[0] == 'IDENTIFIER'
        isIndexStart = nextToken[0] == 'INDEX_START'
        isDot = nextToken[0] == '.'

        # https://github.com/jashkenas/coffee-script/issues/1601
        # @::foo is valid, but @:: behaves inconsistently and is planned for
        # removal. Technically @:: is a stand alone ::, but I think it makes
        # sense to group it into no_stand_alone_at
        if nextToken[0] == '::'
            protoProperty = tokenApi.peek(2)
            isValidProtoProperty = protoProperty[0] == 'IDENTIFIER'

        if spaced or (not isIdentifier and not isIndexStart and
        not isDot and not isValidProtoProperty)
            return true



