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

def make_git_repo_and_return_date(git_dir)
  Dir.chdir(git_dir) do
    Process.wait spawn("git init", out: "/dev/null", err: "/dev/null")
    Process.wait spawn("git branch -m main", out: "/dev/null")
    Process.wait spawn("git config --local init.defaultBranch main", out: "/dev/null", err: "/dev/null")
    Process.wait spawn('git config --local user.name "test-runner"', out: "/dev/null")
    Process.wait spawn('git config --local user.email "test@runner"', out: "/dev/null")
    Process.wait spawn("touch a-file", out: "/dev/null")
    Process.wait spawn("git add .", out: "/dev/null")
    Process.wait spawn('git commit --date "2024-02-01T10:35:48+01:00" --no-gpg-sign -m "reference commit"', out: "/dev/null")
    Process.wait spawn("git rev-parse HEAD", out: "./commit")
    File.read("./commit").strip
  end
end

def deploy_info_yaml_from_git_template(git_commit)
  <<~CONTENT
    ---
    deploy_ref: main
    commit_sha: #{git_commit}
    commit_date: !ruby/object:DateTime 2024-02-01 10:35:48.000000000 +01:00
    commit_subject: reference commit
    origin: :git
  CONTENT
end
