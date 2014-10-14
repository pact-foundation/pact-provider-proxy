# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/provider/proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "pact-provider-proxy"
  spec.version       = Pact::Provider::Proxy::VERSION
  spec.authors       = ["Beth"]
  spec.email         = ["beth@bethesque.com"]
  spec.description   = %q{See summary}
  spec.summary       = %q{Allows verification of a pact against a running provider}
  spec.homepage      = ""
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/bethesque/pact-provider-proxy"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "vendor/rack-reverse-proxy/lib"]

  spec.add_dependency "pact", ">=1.1.1", "~>1.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  # For rack-reverse-proxy
  spec.add_dependency "rack", ">= 1.0.0"
  spec.add_dependency "rack-proxy", "~> 0.5"
end
