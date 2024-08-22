RSpec.describe SimpleCov::Formatter::Inline::Integration do
  after { SimpleCov::Formatter::Inline.reset_config }

  describe '#configure_rspec_rails' do
    subject { described_class.configure_rspec_rails(rspec:, rails:) }

    let(:rspec) { class_double(RSpec) }
    let(:rspec_config) { instance_double(RSpec::Core::Configuration) }

    let(:rails) { double('Rails', root: :fake_root) } # rubocop:todo RSpec/VerifiedDoubles

    before do
      allow(rspec).to receive(:configure).and_yield(rspec_config)
      allow(rspec_config).to receive(:add_formatter)
      allow(rspec_config).to receive(:before)
      allow(described_class).to receive(:configure_formatter)
      allow(RSpec::Core::Formatters).to receive(:register)
    end

    it 'registers the rspec formatter' do
      subject

      expect(RSpec::Core::Formatters)
        .to have_received(:register)
        .with(SimpleCov::Formatter::Inline::RSpecFormatterSkipOnFailure, :dump_failures)
    end

    it 'adds a formatter to the rspec config', :aggregate_failures do
      subject

      expect(rspec_config)
        .to have_received(:add_formatter)
        .with(SimpleCov::Formatter::Inline::RSpecFormatterSkipOnFailure)
    end

    it 'adds a before suite hook that calls configure_formatter', :aggregate_failures do
      subject

      expect(rspec_config).to have_received(:before).with(:suite) do |&block|
        block.call
      end

      expect(described_class).to have_received(:configure_formatter).with(rspec_config:, rails_root: 'fake_root')
    end
  end

  describe '#configure_formatter' do
    subject { described_class.configure_formatter(rspec_config:, rails_root:) }

    let(:rspec_config) { instance_double(RSpec::Core::Configuration, pattern:, files_to_run:) }
    let(:rails_root) { "#{fixture_directory}/fake_rails_root" }
    let(:files_to_run) { ["#{rails_root}/spec/lib/lib_spec.rb", "#{rails_root}/spec/models/model_spec.rb"] }
    let(:pattern) { '**{,/*/**}/*_spec.rb' }
    let(:inclusion_rules) { instance_double(RSpec::Core::InclusionRules, rules: {}) } # no rules means run all

    before { allow(rspec_config).to receive(:inclusion_filter).and_return(inclusion_rules) }

    context 'running all specs' do
      let(:pattern) { '**{,/*/**}/*_spec.rb' }

      it 'does not filter files' do
        expect { subject }.not_to change { SimpleCov::Formatter::Inline.config.files }.from(nil)
      end

      it 'does not supress output' do
        expect { subject }.not_to change { SimpleCov::Formatter::Inline.config.no_output }.from(nil)
      end
    end

    context 'running only a lib spec' do
      let(:files_to_run) { ["#{rails_root}/spec/lib/lib_spec.rb"] }

      it 'does not supress output' do
        expect { subject }.not_to change { SimpleCov::Formatter::Inline.config.no_output }.from(nil)
      end

      it 'filters by the spec file and the file it is testing' do
        expect { subject }
          .to change { SimpleCov::Formatter::Inline.config.files }
          .from(nil).to(["#{rails_root}/spec/lib/lib_spec.rb", "#{rails_root}/lib/lib.rb"])
      end
    end

    context 'running only a model spec' do
      let(:files_to_run) { ["#{rails_root}/spec/models/model_spec.rb"] }

      it 'does not supress output' do
        expect { subject }.not_to change { SimpleCov::Formatter::Inline.config.no_output }.from(nil)
      end

      it 'filters by the spec file and the file it is testing' do
        expect { subject }
          .to change { SimpleCov::Formatter::Inline.config.files }
          .from(nil).to(["#{rails_root}/spec/models/model_spec.rb", "#{rails_root}/app/models/model.rb"])
      end
    end

    context 'filtered to a line of code' do
      let(:files_to_run) { ["#{rails_root}/spec/models/model_spec.rb"] }
      let(:inclusion_rules) do
        instance_double(
          RSpec::Core::InclusionRules,
          rules: {focus: true, locations: {"#{rails_root}/spec/models/model_spec.rb" => [5]}}, # 5 is the line number
        )
      end

      it 'supresses output' do
        expect { subject }
          .to change { SimpleCov::Formatter::Inline.config.no_output }
          .from(nil)
          .to('filtered to line of code')
      end

      it 'does not filter files' do
        expect { subject }.not_to change { SimpleCov::Formatter::Inline.config.files }.from(nil)
      end
    end

    context 'bad spec path' do
      let(:files_to_run) { ['/not/rails/root/spec/models/model_spec.rb'] }

      it 'filters by the spec file and the file it is testing' do
        expect { subject }.to raise_error RuntimeError, 'Spec file must be in rails root.'
      end
    end

    context 'directory provided' do
      let(:files_to_run) { ["#{rails_root}/spec/models"] }

      it 'does not supress output' do
        expect { subject }.not_to change { SimpleCov::Formatter::Inline.config.no_output }.from(nil)
      end

      it 'only filters to the spec directory and does inlcude the covered files' do
        # Existing behaviour. Feels like it should suppress instead.
        expect { subject }
          .to change { SimpleCov::Formatter::Inline.config.files }
          .from(nil).to(["#{rails_root}/spec/models"])
      end
    end
  end
end
