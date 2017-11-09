# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hyku_leaf/version'

Gem::Specification.new do |spec|
  spec.name          = 'hyku_leaf'
  spec.version       = HykuLeaf::VERSION
  spec.authors       = ['Julie Allinson']
  spec.email         = ['julie.allinson@london.ac.uk']

  spec.summary       = 'HykuLeaf adds additional functionality to a Hyku application.'
  spec.description   = 'HykuLeaf adds additional functionality to a Hyku application.'
  spec.homepage      = 'https://github.com/geekscruff/dog_biscuits'
  spec.license       = 'APACHE-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'hyrax', '2.0.0.rc2'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'engine_cart'
  spec.add_development_dependency 'factory_bot_rails', '~> 4.0'
  spec.add_development_dependency 'fcrepo_wrapper'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'solr_wrapper'
  spec.add_development_dependency 'webmock'
end
