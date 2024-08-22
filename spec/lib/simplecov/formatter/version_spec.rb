RSpec.describe SimpleCov::Formatter::Inline do # rubocop:disable RSpec/SpecFilePathFormat
  it 'has a version number' do
    expect(SimpleCov::Formatter::Inline::VERSION).not_to be_nil
  end
end
