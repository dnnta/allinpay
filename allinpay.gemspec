# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "allinpay/version"

Gem::Specification.new do |spec|
  spec.name          = "allinpay"
  spec.version       = Allinpay::VERSION
  spec.authors       = ["qiang.ruan"]
  spec.email         = ["ruan88qiang@sina.com"]

  spec.summary       = %q{Allinpay payment client}
  spec.description   = %q{Allinpay payment client}
  spec.homepage      = "https://github.com/rqiang88/allinpay"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "faraday"
end
