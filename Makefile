tests:
	bin/rspec --format documentation

lint-autofix:
	bin/standardrb --fix-unsafely

lint:
	bin/standardrb --no-fix -f github

static-analysis:
	bin/brakeman --run-all-checks --force --no-exit-on-warn --quiet --no-pager --no-color
