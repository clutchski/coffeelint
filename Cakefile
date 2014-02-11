fs = require 'fs'
browserify = require 'browserify'
CoffeeScript = require 'coffee-script'


copySync = (src, dest) ->
    fs.writeFileSync dest, fs.readFileSync(src)

coffeeSync = (input, output) ->
    coffee = fs.readFileSync(input).toString()
    fs.writeFileSync output, CoffeeScript.compile(coffee)


task 'compile', 'Compile Coffeelint', ->
    console.log 'Compiling Coffeelint...'
    fs.mkdirSync 'lib' unless fs.existsSync 'lib'
    invoke 'compile:browserify'
    invoke 'compile:commandline'

task 'compile:commandline', 'Compiles commandline.js', ->
    coffeeSync 'src/commandline.coffee', 'lib/commandline.js'
    coffeeSync 'src/configfinder.coffee', 'lib/configfinder.js'

task 'compile:browserify', 'Uses browserify to compile coffeelint', ->
    b = browserify [ './src/coffeelint.coffee' ]
    opts =
        standalone: 'coffeelint'
    b.transform require('coffeeify')
    b.bundle(opts).pipe fs.createWriteStream('lib/coffeelint.js')

task 'prepublish', 'Prepublish', ->
    copySync 'package.json', '.package.json'
    packageJson = require './package.json'

    delete packageJson.dependencies.browserify
    delete packageJson.dependencies.coffeeify
    delete packageJson.scripts.install

    fs.writeFileSync 'package.json', JSON.stringify(packageJson, undefined, 2)

    invoke 'compile'

task 'postpublish', 'Postpublish', ->
    copySync '.package.json', 'package.json'

task 'install', 'Install', ->
    unless require("fs").existsSync("lib/commandline.js")
        invoke 'compile'


