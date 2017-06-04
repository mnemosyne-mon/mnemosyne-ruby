# Changelog

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
