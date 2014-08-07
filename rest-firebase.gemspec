# -*- encoding: utf-8 -*-
# stub: rest-firebase 0.9.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rest-firebase"
  s.version = "0.9.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = [
  "Codementor",
  "Lin Jen-Shin (godfat)"]
  s.date = "2014-08-06"
  s.description = "Ruby Firebase REST API client built on top of [rest-core][].\n\n[rest-core]: https://github.com/godfat/rest-core"
  s.email = ["help@codementor.io"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "LICENSE",
  "README.md",
  "Rakefile",
  "TODO.md",
  "doc/intro.md",
  "lib/rest-firebase.rb",
  "rest-firebase.gemspec",
  "task/README.md",
  "task/gemgem.rb",
  "test/test_api.rb"]
  s.homepage = "https://github.com/CodementorIO/rest-firebase"
  s.licenses = ["Apache License 2.0"]
  s.rubygems_version = "2.4.1"
  s.summary = "Ruby Firebase REST API client built on top of [rest-core][]."
  s.test_files = ["test/test_api.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-core>, [">= 3.1.1"])
    else
      s.add_dependency(%q<rest-core>, [">= 3.1.1"])
    end
  else
    s.add_dependency(%q<rest-core>, [">= 3.1.1"])
  end
end
