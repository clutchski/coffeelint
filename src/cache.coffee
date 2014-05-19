fs = require "fs"
path = require "path"
crypto = require "crypto"

ltVer = require("./../package.json").version
csVer = (window?.CoffeeScript or require 'coffee-script').VERSION


module.exports = class Cache

    constructor: (@basepath) ->
        unless fs.existsSync @basepath
            fs.mkdirSync @basepath, 0o755


    path: (source) ->
        path.join @basepath, "#{csVer}-#{ltVer}-#{@prefix}-#{@hash(source)}"


    get: (source) -> JSON.parse fs.readFileSync @path(source), 'utf8'


    set: (source, result) ->
        fs.writeFileSync @path(source), JSON.stringify result


    has: (source) -> fs.existsSync @path source


    hash: (data) ->
        crypto.createHash('md5').update('' + data).digest('hex').substring(0, 8)


    # Use user config as a "namespace" so that
    # when he/she changes it the cache becomes invalid
    setConfig: (config) -> @prefix = @hash JSON.stringify config
