# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "time"
require "scc/deploy_info"

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
    File.read("./commit").strip[0..7]
  end
end

RSpec.describe Scc::DeployInfo do
  describe ".from_git" do
    context "with a valid git repo" do
      it "builds from git repo" do
        Dir.mktmpdir("test-git-dir") do |git_dir|
          git_commit = make_git_repo_and_return_date(git_dir)
          obj = described_class.from_git(root: git_dir)
          expect(obj.extract!.version_string).to eq("main/#{git_commit} @ 01 Feb 2024 10:35")
        end
      end
    end

    context "with an empty dir" do
      it "raises error" do
        Dir.mktmpdir("test-random-dir") do |git_dir|
          obj = described_class.from_git(root: git_dir)
          expect { obj.extract! }.to raise_error(Scc::DeployInfo::Extractor::Git::NotAGitRootError)
        end
      end
    end

    context "with a not existing-dir" do
      it "raises error" do
        Dir.mktmpdir("test-random-dir") do |git_dir|
          obj = described_class.from_git(root: File.join(git_dir, "not-found"))
          expect { obj.extract! }.to raise_error(Scc::DeployInfo::Extractor::Git::NotAGitRootError)
        end
      end
    end
  end
end
