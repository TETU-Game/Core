# TETU Core

A strategy & simulation game in space, inspired by Stellaris PDX

## Installation

Install `git`, `sfml`, `crystal`, `make`, `imgui` (`imgui-sfml` with archlinux).

    make deps
    export LD_LIBRARY_PATH="$(pwd)/cimgui"
    make release
    export LD_LIBRARY_PATH="$(pwd)/lib/imgui-sfml"
    ./core

## Usage

    make run

## Development

* See the wiki <https://git.sceptique.eu/TETU/Core/wiki>.
* See the current kanban: <https://git.sceptique.eu/TETU/Core/projects/10>
* Come talk on IRC **irc://irc.sceptique.eu#TETU**

## Contributing

1. Fork it (<https://git.sceptique.eu/TETU/Core/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Arthur Poulet](https://git.sceptique.eu/Sceptique) - creator and maintainer
