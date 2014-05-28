###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


resolve = require('resolve').sync
path = require("path")
fs   = require("fs")
os   = require("os")
glob = require("glob")
optimist = require("optimist")
thisdir = path.dirname(fs.realpathSync(__filename))
coffeelint = require(path.join(thisdir, "coffeelint"))
configfinder = require(path.join(thisdir, "configfinder"))
ruleLoader = require(path.join(thisdir, 'ruleLoader'))
Cache = require(path.join(thisdir, "cache"))
CoffeeScript = require 'coffee-script'
CoffeeScript.register()

# Return the contents of the given file synchronously.
read = (path) ->
    realPath = fs.realpathSync(path)
    return fs.readFileSync(realPath).toString()

# Return a list of CoffeeScript's in the given paths.
findCoffeeScripts = (paths) ->
    files = []
    for p in paths
        if fs.statSync(p).isDirectory()
            # The glob library only uses forward slashes.
            files = files.concat(glob.sync("#{p}/**/*.coffee"))
        else
            files.push(p)
    return files

# A summary of errors in a CoffeeLint run.
class ErrorReport

    constructor : () ->
        @paths = {}

    getExitCode : () ->
        for path of @paths
            return 1 if @pathHasError(path)
        return 0

    getSummary : () ->
        pathCount = errorCount = warningCount = 0
        for path, errors of @paths
            pathCount++
            for error in errors
                errorCount++ if error.level == 'error'
                warningCount++ if error.level == 'warn'
        return {errorCount, warningCount, pathCount}

    getErrors : (path) ->
        return @paths[path]

    pathHasWarning : (path) ->
        return @_hasLevel(path, 'warn')

    pathHasError : (path) ->
        return @_hasLevel(path, 'error')

    hasError : () ->
        for path of @paths
            return true if @pathHasError(path)
        return false

    _hasLevel : (path, level) ->
        for error in @paths[path]
            return true if error.level == level
        return false



# Return an error report from linting the given paths.
lintFiles = (files, config) ->
    errorReport = new ErrorReport()
    for file in files
        source = read(file)
        literate = CoffeeScript.helpers.isLiterate file

        fileConfig = if config then config else getFallbackConfig(file)

        errorReport.paths[file] = coffeelint.lint(source, fileConfig, literate)
    return errorReport

# Return an error report from linting the given coffeescript source.
lintSource = (source, config, literate = false) ->
    errorReport = new ErrorReport()
    config or= getFallbackConfig()

    errorReport.paths["stdin"] = coffeelint.lint(source, config, literate)
    return errorReport

# Get fallback configuration. With the -F flag found configs in standard places
# will be used for each file being linted. Standard places are package.json or
# coffeelint.json in a project's root folder or the user's home folder.
getFallbackConfig = (filename = null) ->
    unless options.argv.noconfig
        configfinder.getConfig(filename)

# moduleName is a NodeJS module, or a path to a module NodeJS can load.
loadRules = (moduleName, ruleName = undefined) ->
    try
        try
            # Try to find the project-level rule first.
            rulePath = resolve moduleName, {
                basedir: process.cwd()
            }
            ruleModule = require rulePath
        try
            # This seems awkward, but the ?= will prevent it from trying to
            # require if the previous step succeeded without an exception.
            #
            # Globally installed rule
            ruleModule ?= require moduleName

        # Maybe the user used a relative path from the command line. This
        # doesn't make much sense from a config file, but seems natural
        # with the --rules option.
        #
        # No try around this one, an exception here should abort the rest of
        # this function.
        ruleModule ?= require path.resolve(process.cwd(), moduleName)

        # Most rules can export as a single constructor function
        if typeof ruleModule is 'function'
            coffeelint.registerRule ruleModule, ruleName
        else
            # Or it can export an array of rules to load.
            for rule in ruleModule
                coffeelint.registerRule rule
    catch e
        console.error "Error loading #{moduleName}"
        throw e

# These reporters are usually parsed by other software, so I can't just echo a
# warning.  Creating a fake file is my best attempt.
deprecatedReporter = (errorReport, reporter) ->
    errorReport.paths['coffeelint_fake_file.coffee'] ?= []
    errorReport.paths['coffeelint_fake_file.coffee'].push {
        "level": "warn"
        "rule": "commandline"
        "message": "parameter --#{reporter} is deprecated.
            Use --reporter #{reporter} instead"
        "lineNumber": 0
    }
    return reporter

# Publish the error report and exit with the appropriate status.
reportAndExit = (errorReport, options) ->
    strReporter = if options.argv.jslint
        deprecatedReporter(errorReport, 'jslint')
    else if options.argv.csv
        deprecatedReporter(errorReport, 'csv')
    else if options.argv.checkstyle
        deprecatedReporter(errorReport, 'checkstyle')
    else
        options.argv.reporter

    DefaultReporter = require(path.join(thisdir, 'reporters', 'default'))
    CSVReporter = require(path.join(thisdir, 'reporters', 'csv'))
    JSLintReporter = require(path.join(thisdir, 'reporters', 'jslint'))
    CheckstyleReporter = require(path.join(thisdir, 'reporters', 'checkstyle'))
    RawReporter = require(path.join(thisdir, 'reporters', 'raw'))

    SelectedReporter = switch strReporter
        when undefined, 'default' then DefaultReporter
        when 'jslint' then JSLintReporter
        when 'csv' then CSVReporter
        when 'checkstyle' then CheckstyleReporter
        when 'raw' then RawReporter
        else
            try
                reporterPath = resolve strReporter, {
                    basedir: process.cwd()
                }
            catch
                reporterPath = strReporter
            require reporterPath

    reporter = new SelectedReporter errorReport, {
        colorize: not options.argv.nocolor
        quiet: options.argv.q
    }
    reporter.publish()

    process.on 'exit', () ->
        process.exit errorReport.getExitCode()

# Declare command line options.
options = optimist
            .usage("Usage: coffeelint [options] source [...]")
            .alias("f", "file")
            .alias("h", "help")
            .alias("v", "version")
            .alias("s", "stdin")
            .alias("q", "quiet")
            .alias("c", "cache")
            .describe("f", "Specify a custom configuration file.")
            .describe("rules", "Specify a custom rule or directory of rules.")
            .describe("makeconfig", "Prints a default config file")
            .describe("noconfig",
                "Ignores the environment variable COFFEELINT_CONFIG.")
            .describe("h", "Print help information.")
            .describe("v", "Print current version number.")
            .describe("r", "(not used, but left for backward compatibility)")
            .describe('reporter', 'built in reporter (default, csv, jslint,
                checkstyle, raw), or module, or path to reporter file.')
            .describe("csv", "[deprecated] use --reporter csv")
            .describe("jslint", "[deprecated] use --reporter jslint")
            .describe("checkstyle", "[deprecated] use --reporter checkstyle")
            .describe("nocolor", "Don't colorize the output")
            .describe("s", "Lint the source from stdin")
            .describe("q", "Only print errors.")
            .describe("literate",
                "Used with --stdin to process as Literate CoffeeScript")
            .describe("c", "Cache linting results")
            .boolean("csv")
            .boolean("jslint")
            .boolean("checkstyle")
            .boolean("nocolor")
            .boolean("noconfig")
            .boolean("makeconfig")
            .boolean("literate")
            .boolean("r")
            .boolean("s")
            .boolean("q", "Print errors only.")
            .boolean("c")

if options.argv.v
    console.log coffeelint.VERSION
    process.exit(0)
else if options.argv.h
    options.showHelp()
    process.exit(0)
else if options.argv.makeconfig
    console.log JSON.stringify coffeelint.getRules(),
        ((k,v) -> v unless k in ['message', 'description', 'name']), 4
else if options.argv._.length < 1 and not options.argv.s
    options.showHelp()
    process.exit(1)

else
    # Initialize cache, if enabled
    if options.argv.cache
        coffeelint.setCache new Cache(path.join(os.tmpdir(), 'coffeelint'))

    # Load configuration.
    config = null
    unless options.argv.noconfig
        if options.argv.f
            config = JSON.parse read options.argv.f
        else if (process.env.COFFEELINT_CONFIG and
        fs.existsSync(process.env.COFFEELINT_CONFIG))
            config = JSON.parse(read(process.env.COFFEELINT_CONFIG))

    ruleLoader.loadRule(coffeelint, options.argv.rules) if options.argv.rules

    if options.argv.s
        # Lint from stdin
        data = ''
        stdin = process.openStdin()
        stdin.on 'data', (buffer) ->
            data += buffer.toString() if buffer
        stdin.on 'end', ->
            errorReport = lintSource(data, config, options.argv.literate)
            reportAndExit errorReport, options
    else
        # Find scripts to lint.
        paths = options.argv._
        scripts = findCoffeeScripts(paths)

        # Lint the code.
        errorReport = lintFiles(scripts, config, options.argv.literate)
        reportAndExit errorReport, options
