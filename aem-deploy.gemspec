# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aem/deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "aem-deploy"
  spec.version       = Aem::Deploy::VERSION
  spec.authors       = ["Mitch Eaton"]
  spec.email         = ["mitcheaton1@me.com"]

  spec.summary       = %q{A gem to wrap deployments to Adobe Experience Manager}
  spec.description   = %q{A gem to wrap deployments to Adobe Experience Manager}
  spec.homepage      = "https://github.com/mitcheaton1/aem_deploy"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  

  spec.files         = ["lib/aem-deploy.rb",`git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
