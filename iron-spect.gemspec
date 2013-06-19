# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iron-spect/version'

Gem::Specification.new do |gem|
  gem.name          = 'iron-spect'
  gem.version       = IronSpect::VERSION
  gem.authors       = ['Nicholas Terry']
  gem.email         = %w(Nicholas Terry)
  gem.description   = %q{C# project file parser and inspector}
  gem.summary       = %q{C# project file parser and inspector}
  gem.homepage      = ''
  gem.license       = 'Apache2'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_dependency 'xml-simple' '>= 1.1.2'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
end