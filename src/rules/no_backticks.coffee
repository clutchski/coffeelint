
module.exports = class NoBackticks

    rule:
        name: 'no_backticks'
        level : 'error'
        message : 'Backticks are forbidden'
        description: """
            Backticks allow snippets of JavaScript to be embedded in
            CoffeeScript. While some folks consider backticks useful in a few
            niche circumstances, they should be avoided because so none of
            JavaScript's "bad parts", like <tt>with</tt> and <tt>eval</tt>,
            sneak into CoffeeScript.
            This rule is enabled by default.
            """

    tokens: [ "JS" ]

    lintToken : (token, tokenApi) ->
        true
