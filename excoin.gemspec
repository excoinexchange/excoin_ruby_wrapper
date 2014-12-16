# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'excoin/version'

Gem::Specification.new do |spec|
  spec.name          = "excoin"
  spec.version       = Excoin::VERSION
  spec.authors       = ["YT"]
  spec.email         = ["yt@exco.in"]
  spec.summary       = %q{A sophisticiated ruby wrapper for the excoin crypto currency exchange.}
  spec.description   = %q{Excoin wrapper provides all the basic API functionality with an additional abstraction to make accessing the data easier and more efficient. This will be used as a library for writing bots for the Excoin crypto currency exchange.}
  spec.homepage      = "https://exco.in"
  spec.license       = "GPL"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib","config"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "webmock", ">= 1.20.4"
  spec.add_development_dependency "vcr", ">= 2.9.3"
end
