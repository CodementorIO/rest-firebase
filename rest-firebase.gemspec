# -*- encoding: utf-8 -*-
# stub: rest-firebase 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rest-firebase".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = [
  "Codementor".freeze,
  "Lin Jen-Shin (godfat)".freeze]
  s.date = "2016-03-03"
  s.description = "Ruby Firebase REST API client built on top of [rest-core][].\n\n[rest-core]: https://github.com/godfat/rest-core".freeze
  s.email = ["help@codementor.io".freeze]
  s.files = [
  ".gitignore".freeze,
  ".gitmodules".freeze,
  ".travis.yml".freeze,
  "CHANGES.md".freeze,
  "Gemfile".freeze,
  "LICENSE".freeze,
  "README.md".freeze,
  "Rakefile".freeze,
  "TODO.md".freeze,
  "doc/intro.md".freeze,
  "example/daemon.rb".freeze,
  "lib/rest-firebase.rb".freeze,
  "rest-firebase.gemspec".freeze,
  "task/README.md".freeze,
  "task/gemgem.rb".freeze,
  "test/test_api.rb".freeze]
  s.homepage = "https://github.com/CodementorIO/rest-firebase".freeze
  s.licenses = ["Apache License 2.0".freeze]
  s.rubygems_version = "2.6.1".freeze
  s.summary = "Ruby Firebase REST API client built on top of [rest-core][].".freeze
  s.test_files = ["test/test_api.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-core>.freeze, [">= 4.0.0"])
    else
      s.add_dependency(%q<rest-core>.freeze, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<rest-core>.freeze, [">= 4.0.0"])
  end
end
