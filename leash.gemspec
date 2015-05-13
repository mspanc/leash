$:.push File.expand_path("../lib", __FILE__)

require "leash/version"

Gem::Specification.new do |s|
  s.name        = "leash"
  s.version     = Leash::VERSION
  s.authors     = ["Marcin Lewandowski"]
  s.email       = ["marcin@saepia.net"]
  s.homepage    = "http://github.com/mspanc/leash"
  s.summary     = "High-performance OAuth2 provider for a closed set of trusted apps with multiple roles support"
  s.description = "Leash allows you to build an OAuth2 provider for closed set of trusted apps. I can support multiple user types and is designed with high load in mind."

  s.add_dependency "rails", "~> 4.2.1"
  s.add_dependency "ohm"
  s.add_dependency "devise"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 1.9.3'
end