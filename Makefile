.PHONY=docker
docker: gem
	docker build -t t64conv:test .

.PHONY=gem
gem:
	gem build ./t64conv.gemspec
