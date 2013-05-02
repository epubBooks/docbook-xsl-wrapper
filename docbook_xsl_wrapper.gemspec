# -*- encoding: utf-8 -*-
require File.expand_path('../lib/docbook_xsl_wrapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "docbook_xsl_wrapper"
  gem.version       = DocbookXslWrapper::VERSION
  gem.authors       = ["Mike Cook"]
  gem.email         = ["m@mikecook.co.uk"]
  gem.summary       = %q{DocBook XSL Wrapper: validate/transform DocBook 5.x XML documents}
  gem.description   = %q{DocBook XSL Wrapper let's you easily validate then convert DocBook 5.x XML documents to EPUB using the official DocBook XSL stylesheets.}
  gem.license       = 'MIT'

  gem.platform      = Gem::Platform::RUBY
  gem.files         = `git ls-files`.split($\)
  gem.require_paths = ['lib']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency('nokogiri', '~> 1.5.9')

  gem.add_development_dependency('rspec', '~> 2')
end
