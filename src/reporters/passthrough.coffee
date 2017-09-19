# this is used for testing... best not to actually use

RawReporter = require './raw'

module.exports = class PassThroughReporter extends RawReporter
    print: (input) ->
        return JSON.parse(input)

