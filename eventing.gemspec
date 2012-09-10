lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name = 'eventing'
  s.version = '0.0.2'
  s.authors = ['Sitter City']
  s.email = ['dev@sittercity.com']
  s.homepage = 'http://sittercity.com'
  s.summary = 'A simple eventing framework'

  s.files = Dir['lib/**/*.rb', 'app/*.rb']
  s.require_paths = ['lib', 'spec', 'app']
end
