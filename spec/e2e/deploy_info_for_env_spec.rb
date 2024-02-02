# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "time"
require "scc/deploy_info"

RSpec.describe Scc::DeployInfo do
  describe ".for_env" do
    context "for production-like environments" do
      it "looks up into the deploy_info file" do
        Dir.mktmpdir("test-git-dir") do |git_dir|
          path = File.join(git_dir, "deploy_info-test.yml")
          File.write(path, load_file_fixture("deploy_info/valid_deploy_info.yml"))

          obj = described_class.for_env("production", filename: path)
          expect(obj.version_string).to eq("file_ref/file_sha @ 31 Jan 2022 16:47")
        end
      end

      context "when the file does not exist" do
        it "does not raise error" do
          Dir.mktmpdir("test-deploy-info") do |git_dir|
            path = File.join(git_dir, "deploy_info-test.yml")
            File.write(path, load_file_fixture("deploy_info/valid_deploy_info.yml"))

            expect { described_class.for_env("production", filename: path) }.not_to raise_error
          end
        end

        it "falls back to unknown values" do
          Dir.mktmpdir("test-deploy-info") do |git_dir|
            obj = described_class.for_env("production", filename: "random thing here")
            expect(obj.version_string).to eq("UNKNOWN/UNKNOWN @ UNKNOWN")
          end
        end
      end
    end

    context "for local-like environments" do
      it "looks up into the git root" do
        Dir.mktmpdir("test-git-dir") do |git_dir|
          git_commit = make_git_repo_and_return_date(git_dir)[0..7]
          obj = described_class.for_env("development", root: git_dir)
          expect(obj.extract!.version_string).to eq("main/#{git_commit} @ 01 Feb 2024 10:35")
        end
      end

      context "when the dir is not a git root" do
        it "does not raise error" do
          Dir.mktmpdir("test-git-dir") do |git_dir|
            expect { described_class.for_env("development", root: git_dir) }.not_to raise_error
          end
        end

        it "falls back to unknown values" do
          Dir.mktmpdir("test-git-dir") do |git_dir|
            obj = described_class.for_env("development", root: git_dir)
            expect(obj.version_string).to eq("UNKNOWN/UNKNOWN @ UNKNOWN")
          end
        end
      end
    end
  end
end
