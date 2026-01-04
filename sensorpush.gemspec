# frozen_string_literal: true

require_relative 'lib/sensorpush/version'

Gem::Specification.new do |spec|
  spec.name          = 'sensorpush'
  spec.version       = Sensorpush::VERSION
  spec.authors       = ['Michelle Pellon']
  spec.email         = ['122621769+michellepellon@users.noreply.github.com']
  spec.summary       = 'Ruby library for the SensorPush API.'
  spec.description   = 'The SensorPush Ruby library provides convenient access to the SensorPush API ' \
                       'from applications written in the Ruby language.'
  spec.homepage      = 'https://github.com/michellepellon/sensorpush'
  spec.license       = 'ISC'
  spec.required_ruby_version = '>= 4.0.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'documentation_uri' => 'https://rubydoc.info/gems/sensorpush',
    'rubygems_mfa_required' => 'true'
  }

  # Specify which files should be added to the gem when it is released
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features|\.github)/})
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_development_dependency 'rake', '13.2.1'
  spec.add_development_dependency 'rspec', '3.13.0'
  spec.add_development_dependency 'rubocop', '1.75.2'
  spec.add_development_dependency 'webmock', '3.25.1'
end
