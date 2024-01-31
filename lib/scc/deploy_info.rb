# frozen_string_literal: true

require_relative "../scc"
require_relative "../scc/utils"
require_relative "deploy_info/extractor/error"

module Scc
  class DeployInfo
    NULLABLE_ATTRS = %i[deploy_ref commit_sha commit_date commit_subject origin]
    SENTINEL = "UNKNOWN"
    attr_reader(*NULLABLE_ATTRS)
    attr_reader :formatted_date

    def initialize(extractor: nil)
      @deploy_ref = deploy_ref
      @commit_sha = commit_sha
      @commit_date = commit_date
      @commit_subject = commit_subject
      @origin = origin
      @extractor = extractor || Extractor::Dummy.new
    end

    def short_sha = commit_sha.to_s[..7]

    def version_string
      "#{deploy_ref}/#{short_sha} @ #{formatted_date}"
    end

    def to_poro
      {
        "deploy_ref" => deploy_ref,
        "commit_sha" => commit_sha,
        "commit_date" => commit_date,
        "commit_subject" => commit_subject,
        "origin" => origin
      }
    end

    def extract!
      attrs = @extractor.call
      NULLABLE_ATTRS.each do |key|
        value = attrs[key]
        value = SENTINEL if value.nil? || (value.is_a?(String) && value.empty?)

        send("#{key}=".to_sym, value)
      end

      self
    end

    def self.from_git(root: nil)
      root ||= "."
      new(extractor: Extractor::Git.new(root: root))
    end

    def self.from_file(filename: nil)
      filename ||= "deploy_info.yml"
      new(extractor: Extractor::File.new(filename: filename))
    end

    def self.for_env(env, root: nil, filename: nil)
      return from_git(root: root) if %w[test development].include?(env)
      from_file(filename: filename)
    rescue DeployInfo::Extractor::Error
      new
    end

    private

    attr_writer(*NULLABLE_ATTRS)

    def commit_date=(value)
      if value.respond_to?(:strftime)
        @formatted_date = value.strftime("%d %b %Y %H:%M")
      elsif value.is_a?(String) || value.nil?
        @formatted_date = value
      else
        raise ArgumentError.new("value is not a Date-like nor a String type")
      end

      @commit_date = value
    end
  end
end

# require_relative './deploy_info/base'
require_relative "deploy_info/extractor/dummy"
require_relative "deploy_info/extractor/git"
require_relative "deploy_info/extractor/file"
