# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'homebase/version'

Gem::Specification.new do |spec|
  spec.name          = 'homebase'
  spec.version       = Homebase::VERSION
  spec.authors       = ['Brian Davidson']
  spec.email         = ['bsdavidson@gmail.com']

  spec.summary       = 'Host your own dynamic DNS via Digital Ocean'
  spec.homepage      = 'https://github.com/bsdavidson/homebase-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = ['homebase']
  spec.require_paths = ['lib']

  spec.add_dependency 'trollop', '~> 2.1'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'rubocop', '~> 0.35'
end
