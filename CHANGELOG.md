# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-11-23

First tagged release. The ZynAddSubFX setup scripts work on current Raspberry Pi OS (bookworm, trixie), with an optional build from source.

### Changed
- `required-packages.sh` installs the packaged ZynAddSubFX on current Raspberry Pi OS (bookworm, trixie), or with `--from-source` the current build dependencies; several 2017 package names no longer existed (#3)
- `zynlaunch.sh` finds the instrument banks in `/usr/share` (package) or `/usr/local/share` (source build) (#3)
- Both scripts are executable in the repo (#3)

### Added
- README: the ZynAddSubFX box, what each script and flag does, setup as built in 2017, and what's changed on current Raspberry Pi OS (#4)
- MIT license (#1)

[Unreleased]: https://github.com/lucidbeaming/pi-synths/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/lucidbeaming/pi-synths/releases/tag/v1.0.0
