# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

---

### New

### Changes

### Fixes

### Breaks

## [1.14.0] - (2023-07-31)

### New

- Tests with Ruby 3.2

### Changed

- Replace deprecated `!render.view_component` hook with `render.view_component`
- Removed tests for Rails 5.0 and 5.1

## [1.13.0] - 2022-04-14

### Added

- Support for `view_component` gem (#42)
- Support for Ruby 3.1 and Rails 7.0 (formally)

## [1.12.1] - 2022-03-21

### Added

- More commands whitelisted in Redis span metadata (#44)

## [1.12.0] - 2021-08-24

### Added

- Support for `redis` gem (#34)

### Removed

- Support for Ruby 2.4 (hard gem requirement)

## [1.11.0] - 2020-12-18

### Removed

- Support for Ruby 2.4 and Rails 4.2

### Fixed

- Deprecation warnings due to block capture and keyword arguments

## [1.10.0] - 2020-03-05

### Added

- Support for Faraday 1.0

## [1.9.0] - 2019-12-17

### Fixed

- \[Rack] Fix exceptions raised on trace submit corrupting the response

### Added

- Rack: Collect redirect locations (#14)

## [1.8.0] - 2019-10-25

### Added

- Improve compatibility with Rails 6.0

## [1.7.1] - 2019-06-15

### Fixed

- Reworked Faraday probe to not override connection middleware stack

## [1.7.0] - 2019-05-21

### Added

- Restify probe: Attach HTTP response status (#12, #13)

## [1.6.2] - 2019-05-16

### Fixed

- The Faraday probe dropped Faraday's default request encoder

## [1.6.1] - 2019-05-14

### Fixed

- Fix release pipeline; no code changed

## [1.6.0] - 2019-05-14

### Added

- Add faraday probe (#11)

## [1.5.1] - 2019-05-14

### Fixed

- Avoid using internal AMQP constant: Fix compat with amq-protocol 2.3+

## [1.5.0] - 2019-05-14

### Added

- Add ActiveJob perform probe

### Changed

- Capture endpoint names for grape web requests
- `attach_error` accepts errors without backtraces and string messages

## [1.4.0] - 2019-05-14

### Added

- Add global `#attach_error` for manual error reporting

## [1.3.0] - 2019-05-14

### Added

- Add exception serialization to trace and protocol
- Add exception reporting to Sidekiq, Msgr, Rack and Rails

## [1.2.1] - 2019-05-14

### Changed

- Improve AMQP connection recovery
- Fix dynamic probe loading

## [1.2.0] - 2019-05-14

### Added

- Collect response metadata in rack instrumentation

## [1.1.0] - 2019-05-14

### Added

- Add metadata to rack instrumentation
- Add msgr server & client instrumentation
- Add sidekiq client instrumentation
- Add sidekiq server instrumentation
- Add acfs request parameter tracing

## [1.0.1] - 2019-05-14

### Fixed

- Fix issue with `enabled` configuration flag (#1)

## [1.0.0] - 2019-05-14

### Fixed

- Fix issue with acfs middleware on non-tracing contexts

### Changed

- Simplify restify probe to only extend base adapter
- Remove FQDN lookup as it failed on missing RDNS

## 0.2.0 - 2019-05-14

### Changed

- Rename gem to mnemosyne-ruby due to name conflict

### Added

- Add platform identifier

[1.14.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.14.0...v1.13.0
[1.13.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.13.0...v1.12.1
[1.12.1]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.12.1...v1.12.0
[1.12.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.10.0...v1.12.0
[1.11.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.9.0...v1.10.0
[1.9.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.7.1...v1.8.0
[1.7.1]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.6.2...v1.7.0
[1.6.2]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.5.1...v1.6.0
[1.5.1]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/mnemosyne-mon/mnemosyne-ruby/compare/v0.2.0...v1.0.0
