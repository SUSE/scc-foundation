# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "time"
require "scc/deploy_info"

RSpec.describe Scc::DeployInfo do
  describe ".from_git" do
    context "with a valid git repo" do
      it "builds from git repo" do
        Dir.mktmpdir("test-git-dir") do |git_dir|
          git_commit = make_git_repo_and_return_date(git_dir)[0..7]
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
