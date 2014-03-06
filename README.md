CoffeeLint
==========

CoffeeLint is a style checker that helps keep CoffeeScript code
clean and consistent.

For guides on installing, using and configuring CoffeeLint, head over
[here](http://www.coffeelint.org).

To suggest a feature, report a bug, or general discussion, head over
[here](http://github.com/clutchski/coffeelint/issues/).

## Contributing

* New rules should be set to a `warn` level. Developers will expect new changes to NOT break their existing workflow, so unless your change is extremely usefull, default to `warn`. Expect discussion if you choose to use `error`.

* Look at existing rules and test structures when deciding how to name your rule. `no_foo.coffee` is used for many tests designed to catch specific errors, whereas `foo.coffee` is used for tests that are designed to enforce formatting and syntax.

### Steps

1. Fork the repo locally.
2. Run `npm install` to get dependencies.
3. Create your rule in a single file as `src/rules/your_rule_here.coffee`, using the existing
   rules as a guide.
   You may examine the AST and tokens using 
   [http://asaayers.github.io/clfiddle/](http://asaayers.github.io/clfiddle/).
4. Add your test file `my_test.coffee` to the `test` directory.
5. Register your rule in `src/coffeelint.coffee`.
6. Run the test using `coffee vowsrunner.coffee --spec test/your_test_here.coffee`.
7. Squash all commits into a single commit when done.
8. Submit a pull request.

[![Build Status](https://secure.travis-ci.org/clutchski/coffeelint.png)](http://travis-ci.org/clutchski/coffeelint)

