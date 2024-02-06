# frozen_string_literal: true

require "optionparser"
require "yaml"
require "scc/deploy_info"

module Scc
  module Commands
    class BuildManifestFromGit
      def parse_args(argv)
        options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: scc-build-deploy-manifest-from-git [options]"

          opts.on("-o", "--output FILE", "Output file") do |file|
            options[:output_file] = file
          end

          opts.on("-d", "--git-dir PATH", "Git root") do |git_root|
            options[:git_root] = git_root
          end

          opts.on("-h", "--help", "Prints this help") do
            options[:early_exit] = true
            puts opts
          end

          opts.on("-v", "--version", "Prints gem version") do
            options[:early_exit] = true
            puts Scc::VERSION
          end
        end.parse!(argv)

        options
      end

      def call(argv)
        argv = %w[-h] if argv.empty?
        options = parse_args(argv)

        # early exits
        return options[:early_exit] if options[:early_exit]

        deploy_info = Scc::DeployInfo.from_git(root: options[:git_root])
        deploy_info.extract!

        open_and_yield(options[:output_file]) do |f|
          f.puts(YAML.dump(deploy_info.to_poro))
        end

        0
      rescue Scc::DeployInfo::Extractor::Git::NotAGitRootError => e
        puts e.message
        1
      end

      private

      def open_and_yield(filepath)
        output_file = $stdout

        unless filepath.nil? || filepath == "-"
          output_file = File.open(filepath, "w+")
        end

        yield output_file

        output_file.close
      end
    end
  end
end
