# frozen_string_literal: true

require_relative "lib/scc/version"

Gem::Specification.new do |spec|
  spec.name = "scc-foundation"
  spec.version = Scc::VERSION
  # TODO: change this to a more generic SCC Team
  spec.authors = ["Jose D. Gomez R."]
  spec.email = ["jose.gomez@suse.com"]

  spec.summary = "Foundational helpers for our Rails applications"
  spec.description = "A set of helper classes to share across workloads"
  spec.homepage = "https://scc.suse.com/team"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SUSE/scc-foundation"
  spec.metadata["changelog_uri"] = "https://github.com/SUSE/scc-foundation/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
