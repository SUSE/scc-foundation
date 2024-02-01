require "scc/commands/build_manifest_from_git"

RSpec.describe Scc::Commands::BuildManifestFromGit do
  let(:argv) { [] }
  let(:command) { described_class.new }

  describe "no args provided" do
    it "displays the help text" do
      expect { command.call(argv) }.to output(/Usage: scc-build-deploy-manifest-from-git \[options\]/).to_stdout
    end
  end

  describe "--help flag" do
    let(:argv) { %w[--help] }
    it "displays the help text" do
      expect { command.call(argv) }.to output(/Usage: scc-build-deploy-manifest-from-git \[options\]/).to_stdout
    end
  end

  describe "--version flag" do
    let(:argv) { %w[--version] }
    it "displays the version" do
      expect { command.call(argv) }.to output("#{Scc::VERSION}\n").to_stdout
    end
  end

  describe "--git-dir flag" do
    it "generates the manifest" do
      Dir.mktmpdir("command-flag-git-dir") do |root|
        argv = ["--git-dir", root]
        git_commit = make_git_repo_and_return_date(root)
        expected_yaml = deploy_info_yaml_from_git_template(git_commit)

        expect { command.call(argv) }.to output(expected_yaml).to_stdout
      end
    end

    context "in a non-git root" do
      it "prints an error message" do
        Dir.mktmpdir("command-flag-git-dir") do |root|
          argv = ["--git-dir", root]
          expect { command.call(argv) }.to output("'#{root}' is not a git repo\n").to_stdout
        end
      end
    end

    describe "--output flag" do
      it "generates the manifest" do
        Dir.mktmpdir("command-out-flag-git-dir") do |root|
          git_commit = make_git_repo_and_return_date(root)
          argv = ["--git-dir", root, "--output", "-"]

          expected_yaml = deploy_info_yaml_from_git_template(git_commit)

          expect { command.call(argv) }.to output(expected_yaml).to_stdout
        end
      end

      context "with a file path" do
        it "does not print anything to stdout" do
          Dir.mktmpdir("command-out-flag-git-dir") do |root|
            output_file = File.join(root, "deploy_info.yml")
            argv = ["--git-dir", root, "--output", output_file]
            make_git_repo_and_return_date(root)

            expect { command.call(argv) }.to output("").to_stdout
          end
        end

        it "saves the manifest into the file" do
          Dir.mktmpdir("command-out-flag-git-dir") do |root|
            output_file = File.join(root, "deploy_info.yml")
            argv = ["--git-dir", root, "--output", output_file]

            git_commit = make_git_repo_and_return_date(root)
            expected_yaml = deploy_info_yaml_from_git_template(git_commit)

            command.call(argv)
            generated = File.read(output_file)
            expect(generated).to eq(expected_yaml)
          end
        end
      end
    end
  end
end
