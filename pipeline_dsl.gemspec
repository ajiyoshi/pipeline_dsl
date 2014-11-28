# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pipeline_dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "pipeline_dsl"
  spec.version       = PipelineDsl::VERSION
  spec.authors       = ["ajiyoshi-vg"]
  spec.email         = ["Yoichi_Sudo@voyagegroup.com"]
  spec.summary       = %q{UNIX pipe like DSL for test streaming filter.}
  spec.description   = %q{UNIX pipe like DSL for test streaming filter.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
