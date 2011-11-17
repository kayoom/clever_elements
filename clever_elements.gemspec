Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'clever_elements'
  s.version     = '0.0.2'
  s.summary     = 'Clever Elements API Client'
  s.description = 'Clever Elements API Client'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Marian Theisen'
  s.email             = 'marian.theisen@kayoom.com'
  s.homepage          = 'http://github.com/kayoom/clever_elements'

  s.files        = Dir['README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'


  s.add_dependency('activesupport', '>= 3.1.0')
  s.add_dependency('savon', '>= 0.9.7')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-mocks')
  s.add_development_dependency('savon_spec')
end