lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mistral_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'mistral_client'
  spec.version       = MistralClient::VERSION
  spec.authors       = ['Matt Brennan', 'Jeff Cousens', 'Mike Saelim']
  spec.email         = ['opensource@civisanalytics.com']

  spec.summary       = 'Ruby client for Mistral.'
  spec.description   = "A Ruby client for OpenStack's Mistral " \
                       '<https://wiki.openstack.org/wiki/Mistral>.'
  spec.homepage      = 'https://github.com/civisanalytics/mistral_client'
  spec.license       = 'BSD 3-Clause'

  spec.required_ruby_version = '~> 2.3'
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.15'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'pry', '~> 0.13.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.81.0'
  spec.add_development_dependency 'vcr', '~> 5.1'
  spec.add_development_dependency 'webmock', '~> 3.8'
end
