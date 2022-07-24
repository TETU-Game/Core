NAME=core
include .env

all: deps_opt build

run: build
	./$(NAME)
build:
	crystal build src/$(NAME).cr --stats --error-trace -Dentitas_enable_logging
debug:
	crystal build src/$(NAME).cr --stats --error-trace --debug -Dentitas_enable_logging
release:
	crystal build src/$(NAME).cr --stats --release
test:
	crystal spec
deps:
	shards install
deps_update:
	shards update
deps_opt:
	@[ -d lib/ ] || make deps
doc:
	crystal docs ./lib/entitas/src/entitas.cr ./src/core.cr
clean:
	rm $(NAME)

.PHONY: all run build release test deps deps_update clean doc
