# Mnemosyne

The ruby client plugin for the Mnemosyne monitoring system. It extracts full application traces including cross-application requests for distributed applications (services etc.).

Currently supported probes:

* Acfs: Remote calls including tracing middleware
* ActionController: Processing actions and rendering
* ActiveView: Template and Partial rendering
* ActiveRecord: SQL query time
* Grape: Endpoint run, filter and render times
* Mnemosyne: Custom traces
* Responders: render time
* Restify: Remote calls including tracing middleware
* Seahorse (AWS): Remote calls
* Sidekiq: Client and server tracing
* Rack: Middleware for request tracing

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mnemosyne-ruby', '~> 1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mnemosyne

## Usage

TODO

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

