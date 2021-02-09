# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.0] - 2021-02-09

### Added
- Added Ruby 2.7 and 3.0 to the Travis build matrix

### Changed
- Bumped the Ruby version for development to 3.0.0
- Fixed deprecation warnings around positional and keyword arguments from ruby 2.7.0
- Updated rubocop to v1.9.1, and fixed rubocop violations
- Configured rspec to emit warnings, and fix them
- Re-recorded the spec cassettes
- Fixed broken links in the README

### Removed
- Removed Ruby 2.3 and 2.4 from the Travis build matrix

## [1.3.0] - 2020-04-20

### Changed
- Relaxed the constraint on the httparty dependency
- Added Ruby 2.5 and 2.6 to the build matrix
- Updated development dependencies

## [1.2.1] - 2019-11-07

### Added
- A new exception with the request to mistral attached

## [1.2.0] - 2018-12-17

### Added
- A get health endpoint

## [1.1.0] - 2017-12-15

### Added
- Made the input parameter available to execute! so that users can parameterize workflows.

### Changed
- Fixed transient spec failure in task_spec.rb

## 1.0.0 - 2017-10-09

* Initial Release

[Unreleased]: https://github.com/civisanalytics/mistral_client/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/civisanalytics/mistral_client/compare/v1.3.0...v2.0.0
[1.3.0]: https://github.com/civisanalytics/mistral_client/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/civisanalytics/mistral_client/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/civisanalytics/mistral_client/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/civisanalytics/mistral_client/compare/v1.0.0...v1.1.0
