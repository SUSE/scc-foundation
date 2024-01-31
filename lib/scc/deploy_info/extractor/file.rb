# frozen_string_literal: true

require "date"
require "time"
require "yaml"

module Scc
  class DeployInfo
    module Extractor
      class File < Dummy
        class ManifestEmpty < Error
        end

        class ManifestInvalid < Error
        end

        def initialize(filename: "deploy_info.yml")
          @filename = filename
          @origin = "file"
        end

        def call
          loaded_yaml = YAML.safe_load_file(@filename, permitted_classes: [::Date, ::Time, ::DateTime],
            symbolize_names: true)

          raise ManifestEmpty, "Deploy manifest is empty" unless loaded_yaml
          raise ManifestInvalid, "Deploy manifest is not a hash" unless loaded_yaml.is_a?(Hash)

          deploy_info = super.merge(loaded_yaml.compact)

          deploy_info[:origin] = "FILE"
          deploy_info[:commit_date] = Scc::Utils.try_parse_date(deploy_info[:commit_date])
          deploy_info
        rescue ::Psych::Exception # rescue YAML parsing errors
          raise ManifestInvalid, "Could not parse YAML from manifest file"
        end
      end
    end
  end
end
