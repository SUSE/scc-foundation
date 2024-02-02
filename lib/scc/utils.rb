# frozen_string_literal: true

require "date"
require "time"

module Scc
  module Utils
    module_function

    def try_parse_date(date)
      return nil if date.nil?
      return date if date.is_a?(Date) || date.is_a?(Time) || date.is_a?(DateTime)

      DateTime.parse(date)
    rescue Date::Error
      nil
    end
  end
end
