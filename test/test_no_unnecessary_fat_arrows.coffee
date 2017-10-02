path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

runLint = (source) ->
    config = { no_unnecessary_fat_arrows: { level: 'error' } }
    coffeelint.lint source, config

shouldError = (source, numErrors = 1) ->
    topic: source

    'errors for unnecessary arrow': (source) ->
        errors = runLint source
        assert.lengthOf errors, numErrors, "Expected #{numErrors} errors"
        error = errors[0]
        assert.equal error.rule, RULE

shouldPass = (source) ->
    topic: source
    'does not error for necessary arrow': (source) ->
        errors = runLint source
        assert.isEmpty errors, "Expected no errors, got #{errors}"

RULE = 'no_unnecessary_fat_arrows'

vows.describe(RULE).addBatch({

    'empty function': shouldError '=>'
    'simple function': shouldError '=> 1'
    'function with this': shouldPass '=> this'
    'function with this.a': shouldPass '=> this.a'
    'function with @': shouldPass '=> @'
    'function with @a': shouldPass '=> @a'

    'nested simple functions':
        'with inner fat arrow': shouldError '-> => 1'
        'with outer fat arrow': shouldError '=> -> 1'
        'with both fat arrows': shouldError '=> => 1', 2

    'nested functions with this inside':
        'with inner fat arrow': shouldPass '-> => this'
        'with outer fat arrow': shouldError '=> -> this'
        'with both fat arrows': shouldPass '=> => this'

    'nested functions with this outside':
        'with inner fat arrow': shouldError '-> (this; =>)'
        'with outer fat arrow': shouldPass '=> (this; ->)'
        'with both fat arrows': shouldError '=> (this; =>)'

    'deeply nested simple function': shouldError '-> -> -> -> => 1'
    'deeply nested function with this': shouldPass '-> -> -> -> => this'

    'functions with multiple statements': shouldError '''
        f = ->
          x = 2
          z ((a) => x; a)
        '''

    'functions with parameters': shouldError '(a) =>'
    'functions with parameter assignment': shouldPass '(@a) =>'
    'functions with destructuring parameter assignment': shouldPass '({@a}) =>'

    'RequireJS modules containing classes with static methods': shouldPass '''
    define [], ->
      class MyClass
        @omg: ->

    '''

}).export(module)
