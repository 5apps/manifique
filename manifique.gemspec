lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "manifique/version"

Gem::Specification.new do |spec|
  spec.name        = "manifique"
  spec.version     = Manifique::VERSION
  spec.licenses    = ["MIT"]
  spec.authors     = ["Râu Cao"]
  spec.email       = ["raucao@kosmos.org"]
  spec.summary     = "Fetch metadata and icons of Web applications"
  spec.description = "Fetch and process metadata and icons of Web applications from Web App Manifest files, with fallbacks to HTML elements/attributes}"
  spec.homepage    = "https://gitea.kosmos.org/5apps/manifique"
  spec.metadata    = {
    "bug_tracker_uri"   => "https://gitea.kosmos.org/5apps/manifique/issues",
    "source_code_uri"   => "https://gitea.kosmos.org/5apps/manifique"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5.5"
  spec.add_development_dependency "rake", "~> 13.1.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.19.1"
  spec.add_development_dependency "pry", "~> 0.14.2"

  spec.add_runtime_dependency "faraday", "~> 2.9.0"
  spec.add_runtime_dependency "faraday-follow_redirects", "0.3.0"
  spec.add_runtime_dependency "nokogiri", "~> 1.16.0"
end
