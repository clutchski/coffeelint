path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

sources =
    implicit: 'foo: bar'
    ownLine: '''
             x = {
               foo: bar
             }
             '''
    sameLine:
        noSpaces: '{foo: bar}'
        oneSpace: '{ foo: bar }'
        twoSpaces: '{  foo: bar  }'
    splitLine:
        noSpaces: '''
                  {foo,
                   bar} = x
                  '''
        oneSpace: '''
                  { foo,
                    bar } = x
                  '''
        twoSpaces: '''
                   {  foo,
                      bar  } = x
                   '''
    stringInterpolation:
        noSpaces: "\"\#{foo}\""
        oneSpace: "\"\#{ foo }\""

configs =
    zeroSpaces:
        braces_spacing: {level: 'error', spaces: 0}
    oneSpace:
        braces_spacing: {level: 'error', spaces: 1}

shouldPass = (source, config = {}) ->
    topic: coffeelint.lint(source, config)
    'returns no errors': (errors) ->
        assert.isEmpty(errors)

shouldFail = (source, config, errorMessages = []) ->
    context = {}
    context.topic = coffeelint.lint(source, config)
    context["returns #{errorMessages.length} errors"] = (errors) ->
        assert.equal(errors.length, errorMessages.length)
        for error, index in errors
            assert.equal(error.context, errorMessages[index])
    context

vows.describe('braces_spacing').addBatch({

    'disabled by default' :
        'with no spaces': shouldPass(sources.sameLine.noSpaces)
        'with one space': shouldPass(sources.sameLine.oneSpace)


    'enabled with spaces set to 0' :
        'implicit braces':
            shouldPass(sources.implicit, configs.zeroSpaces)

        'braces on their own lines':
            shouldPass(sources.ownLine, configs.zeroSpaces)

        'braces on the line':
            'no spaces inside both braces':
                shouldPass(sources.sameLine.noSpaces, configs.zeroSpaces)

            'one space inside on both braces':
                shouldFail(sources.sameLine.oneSpace,
                           configs.zeroSpaces,
                           ['There should be 0 spaces inside "{"',
                            'There should be 0 spaces inside "}"'])

            'two spaces inside on both braces':
                shouldFail(sources.sameLine.twoSpaces,
                           configs.zeroSpaces,
                           ['There should be 0 spaces inside "{"',
                            'There should be 0 spaces inside "}"'])

        'braces on separate lines':
            'no spaces inside both braces':
                shouldPass(sources.splitLine.noSpaces, configs.zeroSpaces)

            'one space inside on both braces':
                shouldFail(sources.splitLine.oneSpace,
                           configs.zeroSpaces,
                           ['There should be 0 spaces inside "{"',
                            'There should be 0 spaces inside "}"'])

            'two spaces inside on both braces':
                shouldFail(sources.splitLine.twoSpaces,
                           configs.zeroSpaces,
                           ['There should be 0 spaces inside "{"',
                            'There should be 0 spaces inside "}"'])

        'string interpolation':
            'no spaces inside both braces': ->
                shouldPass(sources.stringInterpolation.noSpaces,
                           configs.zeroSpaces)

            'one space inside on both braces':
                shouldPass(sources.stringInterpolation.oneSpace,
                           configs.zeroSpaces)


    'enabled with spaces set to 1' :
        'implicit braces':
            shouldPass(sources.implicit, configs.oneSpace)

        'braces on their own lines':
            shouldPass(sources.ownLine, configs.oneSpace)

        'braces on the line':
            'no spaces inside both braces':
                shouldFail(sources.sameLine.noSpaces,
                           configs.oneSpace,
                           ['There should be 1 space inside "{"',
                            'There should be 1 space inside "}"'])

            'one space inside on both braces':
                shouldPass(sources.sameLine.oneSpace, configs.oneSpace)

            'two spaces inside on both braces':
                shouldFail(sources.sameLine.twoSpaces,
                           configs.oneSpace,
                           ['There should be 1 space inside "{"',
                            'There should be 1 space inside "}"'])

        'braces on separate lines':
            'no spaces inside both braces':
                shouldFail(sources.splitLine.noSpaces,
                           configs.oneSpace,
                           ['There should be 1 space inside "{"',
                            'There should be 1 space inside "}"'])

            'one space inside on both braces':
                shouldPass(sources.splitLine.oneSpace, configs.oneSpace)

            'two spaces inside on both braces':
                shouldFail(sources.splitLine.twoSpaces,
                           configs.oneSpace,
                           ['There should be 1 space inside "{"',
                            'There should be 1 space inside "}"'])

        'string interpolation':
            'no spaces inside both braces':
                shouldPass(sources.stringInterpolation.noSpaces,
                           configs.oneSpace)

            'one space inside on both braces':
                shouldPass(sources.stringInterpolation.oneSpace,
                           configs.oneSpace)


}).export(module)
