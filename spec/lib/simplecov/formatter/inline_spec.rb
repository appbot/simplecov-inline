RSpec.describe SimpleCov::Formatter::Inline do
  after { described_class.reset_config }

  describe '#format' do
    subject { described_class.new.format(result, putter:) }

    let(:putter) { class_double(Kernel) }

    before { allow(putter).to receive(:puts) }

    context 'missing coverage' do
      let(:result) do
        SimpleCov::Result.new({
          File.join(fixture_directory, 'file1.rb') => {
            # 0 means line 3 is uncovered
            'lines' => [1, 1, 0, 1, 1],
            # => 0 means the else branch is uncovered.
            # 2 is an idenditifier, 3 is the start line, 12 is the start col, 3 is the end line and 14 is the end col.
            'branches' => {[:if, 0, 3, 4, 3, 8] => {[:then, 1, 3, 8, 3, 10] => 1, [:else, 2, 3, 12, 3, 14] => 0}},
          },
        })
      end

      it 'prints a yellow message saying coverage is missing' do
        subject

        expect(putter).to have_received(:puts).with(Rainbow('Missing coverage:').yellow)
      end

      it 'prints the missing lines and branches in yellow' do
        subject

        expect(putter).to have_received(:puts).with(Rainbow([
          '/spec/fixtures/file1.rb:3 (line)',
          '/spec/fixtures/file1.rb:3 (branch:else)',
        ].join("\n")).yellow)
      end
    end

    context 'fully covered' do
      let(:result) do
        SimpleCov::Result.new({
          File.join(fixture_directory, 'file1.rb') => {
            'lines' => [1, 1, 1, 1, 1],
            'branches' => {[:if, 0, 3, 4, 3, 8] => {[:then, 1, 3, 8, 3, 10] => 1, [:else, 2, 3, 12, 3, 14] => 1}},
          },
        })
      end

      it 'prints a green message saying fully covered' do
        subject
        expect(putter).to have_received(:puts).with(Rainbow('All branches covered (all files) ✔ ').green)
      end
    end

    context 'output disabled' do
      let(:result) { SimpleCov::Result.new({}) }

      before do
        described_class.config { |config| config.no_output!(reason: 'no output thanks') }
      end

      it 'prints a yellow message saying output is disabled' do
        subject
        expect(putter).to have_received(:puts).with(
          Rainbow('Coverage output skipped. Reason: no output thanks.').yellow,
        )
      end
    end

    context 'filtering out of uncovered files' do
      let(:result) do
        SimpleCov::Result.new({
          File.join(fixture_directory, 'file1.rb') => {'lines' => [1, 1, 1, 1, 1]},
          File.join(fixture_directory, 'file2.rb') => {'lines' => [1, 1, 0, 1, 1]},
        })
      end

      before do
        described_class.config { |config| config.files = [File.join(fixture_directory, 'file1.rb')] }
      end

      it 'prints a green message saying fully covered, but notes only 1 file was considered' do
        subject
        expect(putter).to have_received(:puts).with(Rainbow('All branches covered (1 files) ✔ ').green)
      end
    end
  end

  describe '.config' do
    subject { described_class.config }

    it { is_expected.to have_attributes files: nil }
    it { is_expected.to respond_to :no_output! }

    it 'can change the files' do
      expect { described_class.config { |config| config.files = ['test.txt'] } }
        .to change { described_class.config.files }
        .from(nil)
        .to(['test.txt'])
    end
  end
end
