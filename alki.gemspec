# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alki/version'

Gem::Specification.new do |spec|
  spec.name          = "alki"
  spec.version       = Alki::VERSION
  spec.authors       = ["Matt Edlefsen"]
  spec.email         = ["matt.edlefsen@gmail.com"]
  spec.summary       = %q{Dependency Injection for Ruby}
  spec.description   = %q{Alki (AL-kai) is a Dependency Injection framework for Ruby. Helps organize and scale your project, so you can focus on the important stuff.}
  spec.homepage      = "http://alki.io"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir        = 'exe'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.1.0'

  spec.add_dependency "alki-dsl", "~> 0.6"
  spec.add_dependency "alki-support", "~> 0.7", ">= 0.7.1"
  spec.add_dependency "concurrent-ruby", "~> 1.0"
  spec.add_dependency "ice_nine", "~> 0.11"
end
