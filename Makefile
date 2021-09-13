.PHONY=docker
docker: gem
	docker build -t t64conv:build .

.PHONY=gem
gem:
	gem build ./t64conv.gemspec

.PHONY=docker-test-3.0
docker-test-3.0:
	docker build -f Dockerfile.test -t t64conv:test-3.0 --build-arg RUBY_VERSION=3.0 .
	docker run --rm t64conv:test-3.0

.PHONY=docker-test-2.7
docker-test-2.7:
	docker build -f Dockerfile.test -t t64conv:test-2.7 --build-arg RUBY_VERSION=2.7 .
	docker run --rm t64conv:test-2.7

.PHONY=docker-test-2.6
docker-test-2.6:
	docker build -f Dockerfile.test -t t64conv:test-2.6 --build-arg RUBY_VERSION=2.6 .
	docker run --rm t64conv:test-2.6

.PHONY=docker-test-2.5
docker-test-2.5:
	docker build -f Dockerfile.test -t t64conv:test-2.5 --build-arg RUBY_VERSION=2.5 .
	docker run --rm t64conv:test-2.5

.PHONY=docker-test-2.4
docker-test-2.4:
	docker build -f Dockerfile.test -t t64conv:test-2.4 --build-arg RUBY_VERSION=2.4 .
	docker run --rm t64conv:test-2.4
