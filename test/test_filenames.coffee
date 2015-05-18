vows = require 'vows'
assert = require 'assert'

fs = require('fs')
path = require('path')
glob = require('glob')

batch = {}

thisdir = path.dirname(fs.realpathSync(__filename))
rulesDir = path.join(thisdir, '..', 'src', 'rules')

rules = glob.sync(path.join(rulesDir, '*.coffee'))

hasTests = {
    'has tests': ->
        ruleFilename = this.context.name
        testFilename = path.join(thisdir, 'test_' + ruleFilename)
        assert(fs.existsSync(testFilename), "expected #{testFilename} to exist")

    'has correct filename': ->
        ruleFilename = this.context.name
        Rule = require(path.join(rulesDir, ruleFilename))

        tmp = new Rule
        expectedFilename = tmp.rule.name + '.coffee'

        assert.equal(ruleFilename, expectedFilename)
}

rules.forEach((rule) ->
    filename = path.basename(rule)
    batch[filename] = hasTests
)

vows.describe('filenames').addBatch(batch).export(module)
