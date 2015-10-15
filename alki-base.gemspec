# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alki/base/version'

Gem::Specification.new do |spec|
  spec.name          = "alki-base"
  spec.version       = Alki::Base::VERSION
  spec.authors       = ["Matt Edlefsen"]
  spec.email         = ["matt@xforty.com"]
  spec.summary       = %q{Base library for building applications.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
