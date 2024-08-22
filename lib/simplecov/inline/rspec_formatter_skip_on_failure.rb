module SimpleCov
  module Inline
    class RSpecFormatterSkipOnFailure
      def initialize(output)
        @output = output
      end

      def dump_failures(notification)
        return unless skip_reason(notification:)

        SimpleCov::Inline::Formatter.config do |coverage_config|
          coverage_config.no_output!(reason: skip_reason(notification:))
        end
      end

      private

      def skip_reason(notification:)
        return 'no examples were run' if notification.examples.none?
        return 'some specs failed' if notification.failed_examples.any?

        nil
      end
    end
  end
end
