###
Helpers for finding CoffeeLint config in standard locations, similar to how
JSHint does.
###

fs = require 'fs'
path = require 'path'

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
    loadJSON(fp).coffeelintConfig  if fp

# Parse a JSON file gracefully.
loadJSON = (filename) ->
    try
        JSON.parse(fs.readFileSync(filename).toString())
    catch e
        console.error "Could not load JSON file '%s': %s", filename, e
        null

# Tries to find a configuration file in either project directory (if file is
# given), as either the package.json's 'coffeelintConfig' property, or a project
# specific 'coffeelint.json' or a global 'coffeelint.json' in the home
# directory.
exports.getConfig = (filename = null) ->
    if filename
        dir = path.dirname(path.resolve(filename))
        npmConfig = loadNpmConfig(dir)
        return npmConfig  if npmConfig
        projConfig = findFile("coffeelint.json", dir)
        return loadJSON(projConfig)  if projConfig
    envs = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
    home = path.normalize(path.join(envs, "coffeelint.json"))
    if fs.existsSync(home)
        console.log 'loaded', home
        return loadJSON(home)
