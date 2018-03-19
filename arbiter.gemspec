lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name = 'arbiter'
  s.version = '3.0.1'
  s.authors = ['Sittercity']
  s.email = ['dev@sittercity.com']
  s.homepage = 'https://github.com/sittercity/arbiter'
  s.summary = 'A simple eventing framework'

  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib', 'spec']
end
