path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

runLint = (source) ->
    config = no_unused_variables: level: 'error'
    coffeelint.lint source, config


shouldError = (example) ->
    topic: example.source
    'errors': (source) ->
        errors = runLint source
        assert.lengthOf errors, 1
        assert.equal errors[0].context, example.error.context
        assert.equal errors[0].lineNumber, example.error.lineNumber


shouldPass = (example) ->
    topic: example.source
    'does not error': (source) ->
        errors = runLint source
        assert.isEmpty errors


createBatch = (examples, fn) ->
    result = {}
    for example in examples
        result[example.description] = fn example
    result


usedVariableExamples = [
    description: 'assign and use'
    source: 'x = 1; x'
,
    description: 'destructing object'
    source: '{x} = object; x'
,
    description: 'destructing array'
    source: '[x] = array; x'
,
    description: 'assign to global'
    source: 'global.x = 1'
,
    description: 'assign to this'
    source: 'this.x = 1'
,
    description: 'assign to module'
    source: 'module.exports = 1'
,
    description: 'assign to exports'
    source: 'exports = 1'
,
    description: 'assign to window'
    source: 'window.x = 1'
,
    description: 'looping over array without index'
    source: 'element for element in array'
,
    description: 'looping over array with index'
    source: '{element, index} for element, index in array'
,
    description: 'looping over object without key'
    source: 'value for value of object'
,
    description: 'looping over object with key'
    source: '{key, value} for value, key in object'
]


unusedVariableExamples = [
    description: 'assign and never use'
    error: {context: 'x is unused', lineNumber: 1}
    source: 'x = 1'
,
    description: 'assigned twice'
    error: {context: 'x is unused', lineNumber: 1}
    source: 'x = 1; x = 2'
,
    description: 'destructing object'
    error: {context: 'x is unused', lineNumber: 1}
    source: '{x} = 1'
,
    description: 'destructing array'
    error: {context: 'x is unused', lineNumber: 1}
    source: '{x} = 1'
,
    description: 'scope'
    error: {context: 'x is unused', lineNumber: 2}
    source: '''
        -> x = 1; x # This x is used
        -> x = 1    # This x is unused
        '''
,
    description: 'looping over array without index'
    error: {context: 'element is unused', lineNumber: 1}
    source: '1 for element in array'
,
    description: 'looping over array with index'
    error: {context: 'index is unused', lineNumber: 1}
    source: 'element for element, index in array'
,
    description: 'looping over object without key'
    error: {context: 'value is unused', lineNumber: 1}
    source: '1 for value of object'
,
    description: 'looping over object with key'
    error: {context: 'key is unused', lineNumber: 1}
    source: 'value for value, key in object'
]


vows.describe('no unused variables').addBatch({

    'used variable': createBatch usedVariableExamples, shouldPass
    'unused variable': createBatch unusedVariableExamples, shouldError

}).export(module)
