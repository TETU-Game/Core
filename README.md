# TETU Core

A strategy & simulation game in space, inspired by Stellaris PDX.

[![Build Status](https://drone.sceptique.eu/api/badges/TETU/Core/status.svg)](https://drone.sceptique.eu/TETU/Core)

## Installation

Install `git`, `sfml`, `crystal`, `make`, `imgui` (`imgui-sfml` with archlinux).

    # install dependencies first
    make deps

    # make an optimised build so it's fasteeer
    make release

## Usage

    export LD_LIBRARY_PATH="$(pwd)/lib/imgui-sfml"
    ./core                          # run the server (high performance for data)

## Development

* See the wiki for documentation: <https://git.sceptique.eu/TETU/Core/wiki>.
* See the current kanban for current WIP: <https://git.sceptique.eu/TETU/Core/projects>.
* Come talk on IRC: **irc://irc.sceptique.eu:6697#TETU**.


## Contributing

1. Fork it (<https://git.sceptique.eu/TETU/Core/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Arthur Poulet](https://git.sceptique.eu/Sceptique) - creator and maintainer

## Particular mentions

- Thanks to kalinon for his work and support of <https://github.com/spoved/entitas.cr>.
