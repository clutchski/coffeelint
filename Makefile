LINT_CONFIG = test/fixtures/coffeelint.json

all: test lint

test: compile
	@./node_modules/.bin/vows --spec test/*.coffee
	@echo "tested!"

lint: compile
	@./bin/coffeelint -r -f $(LINT_CONFIG) src/ test/*.coffee
	@echo "linted!"

lint-csv: compile
	@./bin/coffeelint --csv -r -f $(LINT_CONFIG) src/ test/*.coffee
	@echo "linted!"

lint-jslint: compile
	@./bin/coffeelint --jslint -r -f $(LINT_CONFIG) src/ test/*.coffee
	@echo "linted!"

compile:
	@./node_modules/.bin/coffee -c -o lib src
# Add a hack for adding node shebang.
	@echo '#!/usr/bin/env node' | cat - lib/commandline.js > bin/coffeelint
	@chmod +x bin/coffeelint
	@rm lib/commandline.js
	@echo "compiled!"

publish:
	@npm publish

.PHONY: all test lint lint-csv lint-jslint compile publish
