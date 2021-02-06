# MistralClient

[![Build Status](https://travis-ci.org/civisanalytics/mistral_client.svg?branch=master)](https://travis-ci.org/civisanalytics/mistral_client)
[![Gem Version](https://badge.fury.io/rb/mistral_client.svg)](http://badge.fury.io/rb/mistral_client)

MistralClient provides a Ruby interface to a limited subset of
the [Mistral] [API].

[Mistral]: https://docs.openstack.org/mistral/latest/
[API]: https://docs.openstack.org/mistral/latest/user/rest_api_v2.html

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mistral_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mistral_client

## Usage

### Instantiate a Client

The Mistral base URL is required:

```ruby
client = MistralClient.new('https://mistral.local/v2')
```

If running Mistral with a self-signed certificate (*e.g.*, during development),
you can bypass certificate verification by specifying `verify: false`:

```ruby
client = MistralClient.new('https://mistral.local/v2', verify: false)
```

You can also pass in other connection options in the same way you would with
[HTTParty](https://github.com/jnunemaker/httparty):

```ruby
client = MistralClient.new('https://mistral.local/v2', timeout: 20)
```

### Environment Operations

#### Create an Environment

```ruby
environment = client.environment(definition)
```

#### Delete an Environment

```ruby
environment.delete!
```

### Workflow Operations

#### Instantiate a Workflow

```ruby
workflow = client.workflow(definition)
```

You can instantiate a workflow object using an existing Mistral workflow ID:

```ruby
workflow = client.workflow(id: id)
```

or workflow name:

```ruby
workflow = client.workflow(name: name)
```

#### Execute a Workflow

```ruby
workflow.execute!
```

If your workflow uses an environment, you can specify the environment with the
`env` keyword argument:

```ruby
workflow.execute!(env: name)
```

#### Update a Workflow Execution

```ruby
execution.patch(state: 'CANCELLED')
```

#### Update a Task

```ruby
task.patch(state: 'RUNNING', reset: true)
```

#### Delete a Workflow

```ruby
workflow.delete!
```

#### Validate a Workflow

```ruby
client.workflow.valid?(definition)
```

You can also get validation error details:

```ruby
client.workflow.validate(definition)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

### To Record New VCR Cassettes

Recording new cassettes is as simple as ensuring you have a Mistral server
available at the `LOCAL_MISTRAL_URL` defined in `spec/spec_helper.rb` and
running `rake`. To rerecord existing cassettes, simply remove the relevant
cassettes from `spec/cassettes` and run `rake`.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## License

MistralClient is released under the [BSD 3-Clause License](LICENSE.md).
