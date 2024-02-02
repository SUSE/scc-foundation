# frozen_string_literal: true

module Scc
  class DeployInfo
    module Extractor
      class Dummy
        def call
          {
            origin: "UNKNOWN",
            deploy_ref: "UNKNOWN",
            commit_sha: "UNKNOWN",
            commit_date: "UNKNOWN",
            commit_subject: "UNKNOWN"
          }
        end
      end
    end
  end
end
