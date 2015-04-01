# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spotlight/flickr/resources/version'

Gem::Specification.new do |spec|
  spec.name          = "spotlight-flickr-resources"
  spec.version       = Spotlight::Flickr::Resources::VERSION
  spec.authors       = ["Jessie Keck"]
  spec.email         = ["jkeck@stanford.edu"]
  spec.summary       = %q{Harvesting Flickr images into Spotlight}
  spec.homepage      = ""
  spec.license       = "Apache 2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "blacklight-spotlight"
  spec.add_dependency "flickr.rb"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "engine_cart"
  spec.add_development_dependency "jettywrapper"
end
