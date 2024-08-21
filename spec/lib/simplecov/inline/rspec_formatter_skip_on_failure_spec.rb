RSpec.describe SimpleCov::Inline::RSpecFormatterSkipOnFailure do
  after { SimpleCov::Inline::Formatter.reset_config }

  describe '#dump_failures' do
    subject { described_class.new(:output_arg_value_not_used).dump_failures(notification) }

    let(:notification) do
      instance_double(RSpec::Core::Notifications::ExamplesNotification, examples:, failed_examples:)
    end

    context 'no specs ran' do
      let(:examples) { [] }
      let(:failed_examples) { [] }

      it 'supresses output' do
        expect { subject }
          .to change { SimpleCov::Inline::Formatter.config.no_output }
          .from(nil)
          .to('no examples were run')
      end
    end

    context 'specs ran but there were failures' do
      let(:examples) { ['a_spec.rb', 'b_spec.rb'] }
      let(:failed_examples) { ['a_spec.rb'] }

      it 'supresses output' do
        expect { subject }
          .to change { SimpleCov::Inline::Formatter.config.no_output }
          .from(nil)
          .to('some specs failed')
      end
    end

    context 'some specs ran without error' do
      let(:examples) { ['a_spec.rb', 'b_spec.rb'] }
      let(:failed_examples) { [] }

      it 'does not supress output' do
        expect { subject }.not_to change { SimpleCov::Inline::Formatter.config.no_output }.from(nil)
      end
    end
  end
end
