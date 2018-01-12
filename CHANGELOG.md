# Changelog

## 1.5.1

* Avoid using internal AMQP constant: Fix compat with amq-protocol 2.3+

## 1.5.0

* Add ActiveJob perform probe
* `attach_error` accepts errors without backtraces and string messages
* Capture endpoint names for grape web requests

## 1.4.0

* Add global `#attach_error` for manual error reporting

## 1.3.0

* Add exception serialization to trace and protocol
* Add exception reporting to Sidekiq, Msgr, Rack and Rails

## 1.2.1

* Improve AMQP connection recovery
* Fix dynamic probe loading

## 1.2.0

* Collect response metadata in rack instrumentation

## 1.1.0

* Add metadata to rack instrumentation
* Add msgr server & client instrumentation
* Add sidekiq client instrumentation
* Add sidekiq server instrumentation
* Add acfs request parameter tracing

## 1.0.1

* Fix issue with `enabled` configuration flag (#1)

## 1.0.0

* Use semantic versioning
* Fix issue with acfs middleware on non-tracing contexts
* Simplify restify probe to only extend base adapter
* Remove FQDN lookup as it failed on missing RDNS

## 0.2.0

* Rename gem to mnemosyne-ruby due to name conflict
* Add platform identifier

## 0.1.0

* Initial test release
