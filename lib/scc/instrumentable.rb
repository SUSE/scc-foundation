# frozen_string_literal: true

require "active_support/concern"
require "active_support/notifications"
require "active_support/core_ext/string/inflections"

##
# Provides a thin instrumentation layer on top of ActiveSupport::Notifications
#
# Autodetect's the namespace of the event based on the consumer class.
module Scc
  module Instrumentable
    extend ActiveSupport::Concern
    ##
    # Instrument an operation.
    #
    # Hooks into +ActiveSupport::Notifications+ an event.
    #
    # @param event [String] Name of the event
    # @param payload [Hash, nil] Payload for the event.
    #   It is recommended that the payload contains as Plain Old Ruby Objects.
    # @param block [Proc] Actual operation to be performed
    #   +block+ may not be set.
    # @example Instrumenting an operation
    #   # in your class:
    #   include Scc:Instrumentable
    #   # ...
    #   def my_method
    #     instrument('my_method') { 2+2 }
    #   end
    #
    # @example Instrumenting an operation with arguments
    #   # in your class:
    #   include Scc:Instrumentable
    #   # ...
    #   def my_method
    #     instrument('my_method', { extra: :data }) { 2+2 }
    #   end
    #
    # @example Instrumenting an operation without a block
    #   # in your class:
    #   include Scc:Instrumentable
    #   # ...
    #   def my_method
    #     instrument('my_method', { extra: :data })
    #   end

    def instrument(event, payload = nil, &block)
      namespace = instrumentation_namespace
      ActiveSupport::Notifications.instrument("#{event}.#{namespace}", payload, &block)
    end

    ##
    # Instrumentation Namespace
    #
    # The namespace for +ActiveSupport::Notifications+ to report the current
    # event.
    #
    # @returns [String] the instrumentation namespace
    def instrumentation_namespace
      @instrumentation_namespace ||= self.class.instrumentation_namespace
    end

    module ClassMethods
      def instrumentation_namespace
        default_instrumentation_namespace
      end

      protected

      def default_instrumentation_namespace
        name.split("::").map(&:underscore).reverse.join(".")
      end
    end
  end
end
