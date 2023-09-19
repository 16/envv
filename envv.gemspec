# frozen_string_literal: true

require_relative "lib/envv/version"

Gem::Specification.new do |spec|
  spec.name = "envv"
  spec.version = ENVV::VERSION
  spec.authors = ["Fabrice Luraine"]
  spec.email = ["16@asciiland.net"]

  spec.summary = "Validates environment variables requirements with a schema and gives access to their coerced values."
  spec.description = ""
  spec.homepage = "https://github.com/16/envv"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/16/envv"
  spec.metadata["changelog_uri"] = "https://github.com/16/envv/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-schema", "~> 1.13"
  spec.add_dependency "dry-initializer", "~> 3.1"

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.19"
  spec.add_development_dependency "standard", "~> 1.31"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
