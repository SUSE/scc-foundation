# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "time"
require "scc/deploy_info/extractor/git"

RSpec.describe Scc::DeployInfo::Extractor::Git do
  describe ".from_git" do
    context "with a valid git repo" do
      it "builds from git repo" do
        Dir.mktmpdir("test-git-dir") do |git_dir|
          git_commit = make_git_repo_and_return_date(git_dir)
          obj = described_class.new(root: git_dir)
          expect(obj.call).to match({
            deploy_ref: "main",
            commit_sha: git_commit,
            commit_date: DateTime.parse("2024-02-01T10:35:48+01:00"),
            commit_subject: "reference commit",
            origin: :git
          })
        end
      end
    end

    context "with an empty dir" do
      it "raises error" do
        Dir.mktmpdir("test-random-dir") do |git_dir|
          obj = described_class.new(root: git_dir)
          expect { obj.call }.to raise_error(Scc::DeployInfo::Extractor::Git::NotAGitRootError)
        end
      end
    end

    context "with a not existing-dir" do
      it "raises error" do
        Dir.mktmpdir("test-random-dir") do |git_dir|
          obj = described_class.new(root: File.join(git_dir, "not-found"))
          expect { obj.call }.to raise_error(Scc::DeployInfo::Extractor::Git::NotAGitRootError)
        end
      end
    end

    context "when git is not found" do
      let(:mocked_described_class) do
        Class.new(described_class) do
          def git_show_command
            super.tap { |c| c[0] = "gitzzz" }
          end
        end
      end

      it "raises error" do
        Dir.mktmpdir("test-random-dir") do |git_dir|
          obj = mocked_described_class.new(root: git_dir)
          expect { obj.call }.to raise_error(Scc::DeployInfo::Extractor::Git::GitNotFound)
        end
      end
    end
  end
end
