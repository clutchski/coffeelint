#!/bin/bash

# Exit on first failure
set -e

coffee -c -o lib src
./node_modules/browserify/bin/cmd.js -t coffeeify -s coffeelint -e  src/coffeelint.coffee > lib/coffeelint.js
./bin/coffeelint -f test/fixtures/coffeelint.json --rules test/fixtures/custom_rules/ src/coffeelint.coffee

