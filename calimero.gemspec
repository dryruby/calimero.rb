Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "near"
  gem.homepage           = "https://github.com/dryruby/calimero.rb"
  gem.license            = "Unlicense"
  gem.summary            = "Calimero.rb: Calimero Network for Ruby"
  gem.description        = "A Ruby client library for the Calimero Network."
  gem.metadata           = {
    'bug_tracker_uri'   => "https://github.com/dryruby/calimero.rb/issues",
    'changelog_uri'     => "https://github.com/dryruby/calimero.rb/blob/master/CHANGES.md",
    'documentation_uri' => "https://rubydoc.info/gems/calimero",
    'homepage_uri'      => gem.homepage,
    'source_code_uri'   => "https://github.com/dryruby/calimero.rb",
  }

  gem.author             = "Kirill Abramov"
  gem.email              = "septengineering@pm.me"

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CHANGES.md README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()

  gem.required_ruby_version = '>= 3.0'
  gem.add_development_dependency 'rspec', '~> 3.12'
  gem.add_development_dependency 'yard' , '~> 0.9'
end

