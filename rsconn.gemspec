# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsconn/version'


Gem::Specification.new do |spec|
  spec.name          = 'rsconn'
  spec.version       = Rsconn::VERSION
  spec.authors       = ['Dean Morin']
  spec.email         = ['morin.dean@gmail.com']
  spec.summary       = 'Redshift wrapper.'
  spec.description = <<-EOS
    Convience wrapper for using Redshift.
  EOS
  spec.homepage      = 'http://github.com/deanmorin/rsconn'
  spec.license       = 'The Unlicense'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'pg', '~> 0.17'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry', '~> 0.10', '>= 0.10.1'
  spec.add_development_dependency 'pry-nav', '~> 0.2', '>= 0.2.4'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its', '~> 1'
end
