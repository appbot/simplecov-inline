require_relative 'lib/simplecov/formatter/inline/version'

Gem::Specification.new do |spec|
  spec.name = 'simplecov-inline'
  spec.version = SimpleCov::Formatter::Inline::VERSION
  spec.authors = ['tris']
  spec.email = ['developers@appbot.co']

  spec.summary = 'See missed lines of coverage inline with rspec output.'
  spec.homepage = 'https://github.com/appbot/simplecov-inline'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/appbot/simplecov-inline'
  spec.metadata['changelog_uri'] = 'https://github.com/appbot/simplecov-inline/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rainbow', '~> 3.1'
  spec.add_dependency 'simplecov', '~> 0.22'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
