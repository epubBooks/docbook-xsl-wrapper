# -*- encoding: utf-8 -*-
require File.expand_path('../lib/docbook_xsl_wrapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "docbook_xsl_wrapper"
  gem.version       = DocbookXslWrapper::VERSION
  gem.authors       = ["Mike Cook"]
  gem.email         = ["m@mikecook.co.uk"]
  gem.summary       = %q{Wrapper for the DocBook XSL stylesheets for easy XML to EPUB}
  gem.description   = %q{DocBook XSL Wrapper let's you easily convert DocBook XML to EPUB using the official DocBook XSL stylesheets.}

  gem.platform      = Gem::Platform::RUBY
  gem.files         = `git ls-files`.split($\)
  gem.require_paths = ['lib']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.required_ruby_version = '~> 1.9.3'

  gem.add_development_dependency('rspec', '~> 2.13.0')
end
