# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tokenex/version'

Gem::Specification.new do |spec|
  spec.name          = "tokenex"
  spec.version       = Tokenex::VERSION
  spec.authors       = ["Michael Clifford"]
  spec.email         = ["cliffom@gmail.com"]

  spec.summary       = "Provides a Ruby wrapper for the TokenEx API"
  spec.description   = "The TokenEx gem provides a convenient Ruby wrapper for the TokenEx API."
  spec.homepage      = "https://github.com/radpad/tokenex-gem"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1.0"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 2.14", ">= 2.14.0"
end
