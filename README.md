# MistralClient

[![Build Status](https://travis-ci.com/civisanalytics/mistral_client.svg?branch=master)](https://travis-ci.com/civisanalytics/mistral_client)
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


## Docker

This repo is set up with a unique local Docker setup with Docker Compose. With it, you can quickly build a Docker image with your preferred version of Ruby and your preferred version of Rails.

For example, to spin up a container with Ruby 3.3 and Rails 7.1, you have the following options...

<a name="build_image_and_run_container"></a>

### Build Image and Run Container


<a name="start_container_script_with_env_file"></a>

### Using ./start_container.sh with .env File
1. Create a copy of `example.env` named `.env` and place it in the root of the repo.
2. Set the version of Ruby to whatever you desire. `RUBY_VERSION=3.3`
3. Set the version of RAILS to whatever you desire. `RAILS_VERSION=7.1`
4. Run the following command
```bash
./start_container.sh
```

<a name="start_container_with_command_line_arguments"></a>

### Using ./start_container.sh with command line arguments
1. Run the start_container.sh script with the appropriate arguments
```bash
./start_container.sh --ruby 3.3 --rails 7.1
```

<a name="rebuild_docker_image"></a>

### Need to rebuild the docker image?

```bash
./start_container.sh --build
./start_container.sh --rails 6.1 --ruby 3.1 --build
```

<a name="start_container_immediately_run_command"></a>

### Want to start the container and immediately run a command?

```bash
  ./start_container.sh --command "echo 'hello world'"
  ./start_container.sh --command rspec

  ./srart_container.sh --rails 6.1 --ruby 3.2 --command "echo 'hello world'"
  ./srart_container.sh --rails 6.1 --ruby 3.2 --command "echo rspec
```


### To Record New VCR Cassettes

Recording new cassettes is as simple as ensuring you have a Mistral server
available at the `LOCAL_MISTRAL_URL` defined in `spec/spec_helper.rb` and
running `rake`. To rerecord existing cassettes, simply remove the relevant
cassettes from `spec/cassettes` and run `rake`.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## License

MistralClient is released under the [BSD 3-Clause License](LICENSE.md).
