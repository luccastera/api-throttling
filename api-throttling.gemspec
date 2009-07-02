# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{api-throttling}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luc Castera", "John Duff"]
  s.date = %q{2009-07-02}
  s.description = %q{TODO}
  s.email = %q{duff.john@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "TODO.md",
    "lib/api_throttling.rb",
    "test/test_api_throttling.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jduff/api-throttling/tree}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rack Middleware to impose a rate limit on a web service (aka API Throttling)}
  s.test_files = [
    "test/test_api_throttling.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
