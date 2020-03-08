Gem::Specification.new do |spec|
  spec.name = "bgg-hotness-cli"
  spec.version = "0.1.2"
  spec.authors = ["'Josh Ellis'"]
  spec.email = ['joshe523@gmail.com']

  spec.summary = "Quickly browse the hottest games on BoardGameGeek"
  spec.description = "Command Line Interface that utilizes the API of BoardGameGeek.com to list hot boardgames."
  spec.homepage = "https://github.com/imjoshellis/bgg-hotness-cli"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_runtime_dependency "nokogiri", "~> 1.10.4"
  spec.add_runtime_dependency "launchy", "~> 2.5.0"
  spec.add_runtime_dependency "tty-prompt", "~> 0.20.0"
end
