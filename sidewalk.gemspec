gemspec = Gem::Specification.new do |s|
  s.name = 'sidewalk'
  s.version = '0.0.3'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Fred Emmott']
  s.email = ['sidewalk-gem@fredemmott.co.uk']
  s.homepage = 'https://github.com/fredemmott/sidewalk'
  s.summary = 'A lightweight web framework'
  s.require_paths = ['lib']
  s.files = Dir['lib/**/*']

  s.add_dependency 'activesupport', '~>3.2'
  s.add_dependency 'rack', '~>1.4'

  if RUBY_VERSION.start_with? '1.8'
    s.add_dependency 'oniguruma', '~> 1.1'
  end
end
