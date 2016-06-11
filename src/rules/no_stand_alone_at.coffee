module.exports = class NoStandAloneAt

    rule:
        name: 'no_stand_alone_at'
        level: 'ignore'
        message: '@ must not be used stand alone'
        description: '''
            This rule checks that no stand alone @ are in use, they are
            discouraged. Further information in CoffeeScript issue <a
            href="https://github.com/jashkenas/coffee-script/issues/1601">
            #1601</a>
            '''

    tokens: ['@']

    lintToken: (token, tokenApi) ->
        [nextToken] = tokenApi.peek()
        noSpace = not token.spaced
        # TODO: after <1.10.0 is not supported, remove 'IDENTIFIER' here
        isProp = nextToken in ['IDENTIFIER', 'PROPERTY']
        isAStart = nextToken in ['INDEX_START', 'CALL_START'] # @[] or @()
        isDot = nextToken is '.'

        # https://github.com/jashkenas/coffee-script/issues/1601
        # @::foo is valid, but @:: behaves inconsistently and is planned for
        # removal. Technically @:: is a stand alone ::, but I think it makes
        # sense to group it into no_stand_alone_at
        #
        # TODO: after v1.10.0 is not supported, remove 'IDENTIFIER' here
        isProtoProp = nextToken is '::' and
            tokenApi.peek(2)?[0] in ['IDENTIFIER', 'PROPERTY']

        # Return an error after an '@' token unless:
        # 1: there is a '.' afterwards (isDot)
        # 2: there isn't a space after the '@' and the token following the '@'
        # is an property, the start of an index '[' or is an property after
        # the '::'
        unless (isDot or (noSpace and (isProp or isAStart or isProtoProp)))
            return true
