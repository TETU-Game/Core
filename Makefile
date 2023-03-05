NAME=core
include .env

all: deps_opt build

run: build
	./$(NAME)
build:
	crystal build src/$(NAME).cr --stats --error-trace -Dentitas_enable_logging
build_entitas_logging:
	crystal build src/$(NAME).cr --stats --error-trace -Dentitas_enable_logging
debug:
	crystal build src/$(NAME).cr --stats --error-trace -Dentitas_enable_logging Dentitas_debug_generator
  # I did not enabled --debug because it crashes.
  # Crystal issue seem already open but nothing yet as been fixed. Maybe I can fix it?

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

log_level_debug:
	sd "spoved_logger level: :\\w+" "spoved_logger level: :debug" src/**.cr
log_level_info:
	sd "spoved_logger level: :\\w+" "spoved_logger level: :info" src/**.cr

.PHONY: all run build release test deps deps_update clean doc log_level_debug log_level_info
