require 'rainbow'

module SimpleCov
  module Formatter
    class Inline
      Result = Struct.new(:file, :start_line, :end_line, :type) do
        def to_s
          lines = [start_line, end_line].uniq.join('-')
          "#{file}:#{lines} (#{type})"
        end
      end

      Config = Struct.new(:files) do
        def no_output!(reason:)
          @no_output = reason
        end

        attr_reader :no_output
      end

      def self.reset_config = @config = Config.new
      reset_config

      def self.config(&block)
        return @config if block.nil?

        block.call(@config)

        return if @config.files.nil?

        @config.files = @config.files.to_set.freeze
      end

      def format(result, putter: Kernel)
        missing_coverage = process_files(filtered_files(result:).reject { |file| fully_covered?(file) })
        success_message = build_success_message(missing_coverage:)

        if success_message
          putter.puts success_message
          return
        end

        putter.puts
        putter.puts Rainbow('Missing coverage:').yellow
        putter.puts Rainbow(missing_coverage).yellow
        putter.puts
      end

      private

      def build_success_message(missing_coverage:)
        if self.class.config.no_output
          return Rainbow("Coverage output skipped. Reason: #{self.class.config.no_output}.").yellow
        end

        return Rainbow("All branches covered (#{human_filter} files) ✔ ").green if missing_coverage.empty?

        nil
      end

      def fully_covered?(file)
        [file.covered_percent, file.branches_coverage_percent].all? { |coverage| coverage == 100 }
      end

      def human_filter
        self.class.config.files&.length || 'all'
      end

      def filtered_files(result:)
        filter = self.class.config.files

        return result.files if filter.nil?

        result.files.filter { |file| filter.include?(file.filename) }
      end

      def process_files(files)
        files.map do |file|
          [
            build_line_coverage(file),
            build_branch_coverage(file),
          ]
        end.flatten.compact.join("\n")
      end

      def build_line_coverage(file)
        file.missed_lines.map do |uncovered|
          # uncovered is a SimpleCov::SourceFile::Line
          Result.new(file.project_filename, uncovered.line_number, uncovered.line_number, 'line')
        end
      end

      def build_branch_coverage(file)
        file.missed_branches.map do |uncovered|
          # uncovered is a SimpleCov::SourceFile::Branch
          Result.new(file.project_filename, uncovered.report_line, uncovered.report_line, "branch:#{uncovered.type}")
        end
      end
    end
  end
end
