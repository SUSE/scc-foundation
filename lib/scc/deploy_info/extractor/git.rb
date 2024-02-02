# frozen_string_literal: true

require "scc/utils"
require "English"

module Scc
  class DeployInfo
    module Extractor
      class Git < Dummy
        GIT_SHOW_SEPARATOR = "|-*-|"
        GIT_SHOW_FORMAT = %w[%D %H %s %aI].join(GIT_SHOW_SEPARATOR).freeze

        class NotAGitRootError < Error
        end

        attr_reader :root

        def initialize(root: ".")
          @root = root
        end

        def call
          parts = Dir.chdir(root) do
            IO.popen(git_show_command, err: "/dev/null", &:read).strip.split(GIT_SHOW_SEPARATOR)
          end

          raise NotAGitRootError, "'#{root}' is not a git repo" unless $CHILD_STATUS.success?

          deploy_ref, commit_sha, commit_subject, commit_date = parts
          deploy_ref = deploy_ref.split(" ")[2].to_s.tr(",", "")

          commit_date = Utils.try_parse_date(commit_date)

          super.merge({
            deploy_ref: deploy_ref,
            commit_sha: commit_sha,
            commit_date: commit_date,
            commit_subject: commit_subject,
            origin: :git
          }.compact)
        rescue Errno::ENOENT
          raise NotAGitRootError, "git root not found at '#{root}'"
        end

        private

        def git_show_command
          %w[git show -s].append("--format=tformat:#{GIT_SHOW_FORMAT}", "@")
        end
      end
    end
  end
end
