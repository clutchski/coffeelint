The post-test process involves linting all of the files under `test/`. By
writing this file in Literate (style?) it verifies that literate files are
automatically detected.


    path = require 'path'
    vows = require 'vows'
    assert = require 'assert'
    coffeelint = require path.join('..', 'lib', 'coffeelint')

    vows.describe('literate').addBatch({

Markdown uses trailing spaces to force a line break.

        'Trailing whitespace in markdown' :

            topic :

The line of code is written weird because I had trouble getting the 4 space
prefix in place.

The third line in this topic is used to test support for a trailing tab whitespace.

                """This is some `Markdown`.  \n\n
                \n    x = 1234  \n    y = 1  \n	z = 1
                """

            'is ignored' : (source) ->

The 3rd parameter here indicates that the incoming source is literate.

                errors = coffeelint.lint(source, {}, true)

This intentionally includes trailing whitespace in code so it also verifies
that the way `Markdown` spaces are stripped are not also stripping code.

                assert.equal(errors.length, 2)

    }).export(module)
