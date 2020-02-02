PROJECT_NAME := rate_limiting
GIT_SHA = $(shell git rev-parse --verify HEAD --short)
GIT_TAG = $(shell git describe)
GITHUB_TAG = $(shell git describe --tags)

all: test publish

.PHONY: test
test:
	rm -Rf _build
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	mix compile
	mix test --color --cover

.PHONY: publish
publish:
	mix hex.build
	mix hex.publish --yes

.PHONY: next-tag
next-tag:
ifndef TAG
	$(error TAG is not set)
endif

.PHONY: create-tag
create-tag: next-tag
	git fetch --tags lenfree
	git tag -a v$(TAG) -m "v$(TAG)"
	git push lenfree v$(TAG)

.PHONY: watch
watch:
	watchexec -w . mix test