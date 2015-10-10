path        = require 'path'
vows        = require 'vows'
assert      = require 'assert'
coffeelint  = require path.join('..', 'lib', 'coffeelint')

RULE = 'no_empty_functions'

runLint = (source) ->
    config = no_empty_functions: level: 'error'
    coffeelint.lint source, config

shouldError = (source, numErrors = 1, errorNames = ['no_empty_functions']) ->
    topic: source
    'errors for empty function': (source) ->
        errors = runLint source
        assert.lengthOf errors, numErrors, "Expected #{numErrors} errors, got
            [#{errors.map( (error) -> error.name).join ', '}] instead"
        for errorName in errorNames
            assert.notEqual errors.indexOf errorName, -1

shouldPass = (source) ->
    topic: source
    'does not error for empty function': (source) ->
        errors = runLint source
        assert.isEmpty errors, "Expected no errors, got
            [#{errors.map( (error) -> error.name).join ', '}] instead"

vows.describe(RULE).addBatch({
    'empty fat-arrow function': shouldError(
        '=>', 2)
    'empty function': shouldError(
        '->')
    'function with undefined statement': shouldPass(
        '-> undefined')
    'function within function with undefined statement': shouldPass(
        '-> -> undefined')
    'empty fat arrow function within a function ': shouldError(
        '-> =>', 2)
    'empty function within a function ': shouldError(
        '-> ->')
    "empty function as param's default value": shouldError(
        'foo = (empty=(->)) -> undefined')
    "non-empty function as param's default value": shouldPass(
        'foo = (empty=(-> undefined)) -> undefined')
    'empty function with implicit instance member assignment as param':
        shouldError('foo = (@_fooMember) ->')

}).export(module)
