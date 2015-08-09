###
Helpers for finding CoffeeLint config in standard locations, similar to how
JSHint does.
###

fs = require 'fs'
path = require 'path'
stripComments = require 'strip-json-comments'
resolve = require('resolve').sync

# Cache for findFile
findFileResults = {}

# Searches for a file with a specified name starting with 'dir' and going all
# the way up either until it finds the file or hits the root.
findFile = (name, dir) ->
    dir = dir or process.cwd()
    filename = path.normalize(path.join(dir, name))
    return findFileResults[filename]  if findFileResults[filename]
    parent = path.resolve(dir, "../")
    if fs.existsSync(filename)
        findFileResults[filename] = filename
    else if dir is parent
        findFileResults[filename] = null
    else
        findFile name, parent

# Possibly find CoffeeLint configuration within a package.json file.
loadNpmConfig = (dir) ->
    fp = findFile("package.json", dir)
    loadJSON(fp)?.coffeelintConfig  if fp

# Parse a JSON file gracefully.
loadJSON = (filename) ->
    try
        JSON.parse(stripComments(fs.readFileSync(filename).toString()))
    catch e
        process.stderr.write "Could not load JSON file '#{filename}': #{e}"
        null

# Tries to find a configuration file in either project directory (if file is
# given), as either the package.json's 'coffeelintConfig' property, or a project
# specific 'coffeelint.json' or a global 'coffeelint.json' in the home
# directory.
getConfig = (dir) ->

    npmConfig = loadNpmConfig(dir)
    return npmConfig  if npmConfig
    projConfig = findFile("coffeelint.json", dir)
    return loadJSON(projConfig)  if projConfig

    envs = process.env.USERPROFILE or process.env.HOME or process.env.HOMEPATH
    home = path.normalize(path.join(envs, "coffeelint.json"))
    if fs.existsSync(home)
        return loadJSON(home)

# configfinder is the only part of coffeelint that actually has the full
# filename and can accurately resolve module names. This will find all of the
# modules and expand them into full paths so that they can be found when the
# source and config are passed to `coffeelint.lint`
expandModuleNames = (dir, config) ->
    for ruleName, data of config when data?.module?
        config[ruleName]._module = config[ruleName].module
        config[ruleName].module = resolve data.module, {
            basedir: dir
        }

    coffeelint = config.coffeelint
    if coffeelint?.transforms?
        coffeelint._transforms = coffeelint.transforms
        coffeelint.transforms = coffeelint.transforms.map (moduleName) ->
            return resolve moduleName, {
                basedir: dir
            }
    if coffeelint?.coffeescript?
        coffeelint._coffeescript = coffeelint.coffeescript
        coffeelint.coffeescript = resolve coffeelint.coffeescript, {
            basedir: dir
        }

    config

extendConfig = (config) ->
    unless config.extends
        return config

    parentConfig = require config.extends
    extendedConfig = {}

    for ruleName, rule of config
        extendedConfig[ruleName] = rule
    for ruleName, rule of parentConfig
        extendedConfig[ruleName] = config[ruleName] or rule

    return extendedConfig


exports.getConfig = (filename = null) ->
    if filename
        dir = path.dirname(path.resolve(filename))
    else
        dir = process.cwd()

    config = getConfig(dir)

    if config
        config = extendConfig(config)
        config = expandModuleNames(dir, config)

    config
