module SimpleCov
  module Inline
    class Integration
      class << self
        def configure_rspec_rails(rspec: RSpec, rails: Rails)
          RSpec::Core::Formatters.register SimpleCov::Inline::RSpecFormatterSkipOnFailure, :dump_failures

          rspec.configure do |rspec_config|
            rspec_config.add_formatter SimpleCov::Inline::RSpecFormatterSkipOnFailure
            rspec_config.before(:suite) do
              SimpleCov::Inline::Integration.configure_formatter(rspec_config:, rails_root: rails.root.to_s)
            end
          end
        end

        def configure_formatter(rspec_config:, rails_root:)
          # Restrict coverage reporting to spec files and the file they are testing.
          # Note files_to_run contains all spec files when running rspec with no args,
          # so in that case do not filter.
          # To do so would exclude files that are covered but not directly tested.
          return if running_all_specs?(rspec_config:, rails_root:)

          SimpleCov::Inline::Formatter.config do |coverage_config|
            if rspec_config.inclusion_filter.rules.key?(:locations)
              # Skip coverage output if running rspec against a single line.
              # e.g. spec/x_spec.rb:123
              coverage_config.no_output!(reason: 'filtered to line of code')
            else
              coverage_config.files = rspec_config.files_to_run.flat_map do |spec_path|
                [spec_path, rails_path_under_test(spec_path:, rails_root:)]
              end.compact
            end
          end
        end

        private

        def running_all_specs?(rspec_config:, rails_root:)
          Dir.glob("#{rails_root}#{rspec_config.pattern}").to_set == rspec_config.files_to_run.to_set
        end

        def rails_path_under_test(spec_path:, rails_root:)
          # Mappings
          # /app/spec/lib/x_spec.rb -> /app/lib/x.rb
          # /app/spec/controller/y_spec.rb -> /app/app/controllers/y.rb
          raise 'Spec file must be in rails root.' unless spec_path.start_with?(rails_root)

          _spec_root, spec_type, *other_directories, filename = spec_path[(rails_root.length + 1)..].split('/')

          return if filename.nil?

          filename_under_test = filename.gsub(/_spec.rb$/, '.rb')

          if spec_type == 'lib'
            [rails_root, spec_type, *other_directories, filename_under_test]
          else
            [rails_root, 'app', spec_type, *other_directories, filename_under_test]
          end.compact.join('/')
        end
      end
    end
  end
end
