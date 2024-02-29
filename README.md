# Mnemosyne

The ruby client plugin for the Mnemosyne monitoring system. It extracts full application traces including cross-application requests for distributed applications (services etc.).

Supported probes:

* Acfs: Remote calls including tracing middleware
* ActionController: Processing actions and rendering
* ActionDispatch: Error capturing
* ActiveJob: Background job execution
* ActiveRecord: SQL query time
* ActiveView: Template and Partial rendering
* Faraday: HTTP client operations and tracing injection
* Grape: Endpoint run, filter and render times
* Mnemosyne: Custom traces
* Msgr: Event publishing and consumer processing
* Rack: Middleware for request tracing
* Redis: Client operations
* Responders: render time
* Restify: Remote calls including tracing middleware
* Sidekiq: Client and server tracing
* ViewComponent: Component rendering (needs [additional configuration](https://viewcomponent.org/guide/instrumentation.html))

## Installation

Add this line to your Gemfile:

```ruby
gem 'mnemosyne-ruby', '~> 2.0'
```

Note: Removing support for ancient Ruby or Rails versions will not result in a new major. Please be extra careful when using ancient Ruby or Rails versions and updating gems.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
