
module.exports = class TransformMessesUpLineNumbers

    rule:
        name: 'transform_messes_up_line_numbers'
        level: 'warn'
        message: 'Transforming source messes up line numbers'
        description:
            """
            This rule detects when changes are made by transform function,
            and warns that line numbers are probably incorrect.
            """

    tokens: []

    lintToken: (token, tokenApi) ->
        # implemented before the tokens are created, using the entire source.
