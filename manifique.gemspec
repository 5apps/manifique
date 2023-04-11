lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "manifique/version"

Gem::Specification.new do |spec|
  spec.name          = "manifique"
  spec.version       = Manifique::VERSION
  spec.authors       = ["Sebastian Kippe"]
  spec.email         = ["sebastian@kip.pe"]

  spec.summary       = %q{Fetch metadata and icons of Web applications}
  spec.description   = %q{Fetch metadata and icons of Web applications}
  spec.homepage      = "https://5apps.com/opensource"
  spec.license       = "AGPL"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.4.2"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "guard", "~> 2.14.2"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"

  spec.add_runtime_dependency "faraday", "~> 0.9.2", "< 0.10.0"
  spec.add_runtime_dependency "faraday_middleware", "~> 0.12.2"
  spec.add_runtime_dependency "nokogiri", ">= 1.10.4", "< 1.15.0"
end
