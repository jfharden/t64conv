.PHONY=build-docker
build-docker: build-gem
	docker build -t t64conv:test .

.PHONY=build-gem
build-gem:
	gem build ./t64conv.gemspec
