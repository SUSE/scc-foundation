# frozen_string_literal: true

require "simplecov"
require "simplecov-cobertura"

SimpleCov.start do
  formatter SimpleCov::Formatter::CoberturaFormatter if ENV["CI"]
  enable_coverage :branch
end

require "debug"
require "scc"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def load_file_fixture(fixture_path)
  path = File.join("spec/fixtures", fixture_path)
  File.read(path)
end
