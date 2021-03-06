# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pricebr_apple/version'

Gem::Specification.new do |spec|
  spec.name          = "pricebr_apple"
  spec.version       = PricebrApple::VERSION
  spec.authors       = ["Eduardo Alencar"]
  spec.email         = ["lebas66@gmail.com"]

  spec.summary       = %q{Prices of Apple products.}
  spec.description   = %q{Prices of Apple products.}
  spec.homepage      = "https://facebook.com/Solution4Mac"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry", "~> 0.10.1"
  
  spec.add_dependency "nokogiri",  "1.6.1"
end

