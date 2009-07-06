# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{api-throttling}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luc Castera", "John Duff"]
  s.date = %q{2009-07-06}
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
    "VERSION.yml",
    "lib/api_throttling.rb",
    "lib/handlers/active_support_cache_store_handler.rb",
    "lib/handlers/handlers.rb",
    "lib/handlers/hash_handler.rb",
    "lib/handlers/memcache_handler.rb",
    "lib/handlers/redis_handler.rb",
    "test/test_api_throttling.rb",
    "test/test_api_throttling_hash.rb",
    "test/test_api_throttling_memcache.rb",
    "test/test_handlers.rb",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jduff/api-throttling/tree}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rack Middleware to impose a rate limit on a web service (aka API Throttling)}
  s.test_files = [
    "test/test_api_throttling.rb",
    "test/test_api_throttling_hash.rb",
    "test/test_api_throttling_memcache.rb",
    "test/test_handlers.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<context>, [">= 0"])
    else
      s.add_dependency(%q<context>, [">= 0"])
    end
  else
    s.add_dependency(%q<context>, [">= 0"])
  end
end
