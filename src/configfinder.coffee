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
    findFileResults[filename]  if findFileResults[filename]
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
    require(fp).coffeelintConfig  if fp

# Tries to find a configuration file in either project directory (if file is
# given), as either the package.json's 'coffeelintConfig' property, or a project
# specific '.coffeelintrc' or a global '.coffeelintrc' in the home directory.
exports.getConfig = (filename = null) ->
    if filename
        dir = path.dirname(path.resolve(filename))
        npmConfig = loadNpmConfig(dir)
        return npmConfig  if npmConfig
        projConfig = findFile(".coffeelintrc", dir)
        return readJSON(projConfig)  if projConfig
    envs = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE
    home = path.normalize(path.join(envs, ".coffeelintrc"))
    return readJSON(home)  if fs.existsSync(home)

readJSON = (filename) ->
    JSON.parse(fs.readFileSync(filename).toString())
