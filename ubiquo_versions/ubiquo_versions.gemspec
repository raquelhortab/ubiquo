# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ubiquo_versions/version"

Gem::Specification.new do |s|
  s.name        = "ubiquo_versions"
  s.version     = UbiquoVersions.version
  s.authors     = ["Jordi Beltran", "Albert Callarisa", "Bernat Foj", "David Lozano", "Toni Reina", "Ramon Salvadó"]
  s.homepage    = "http://www.ubiquo.me"
  s.summary     = %q{Provides a versioning system to record the state of your model instances and see in a history how these evolved}
  s.description = %q{Provides a versioning system to record the state of your model instances and see in a history how these evolved}

  s.rubyforge_project = "ubiquo_versions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "ubiquo_core", ["~> 0.9.0.b1"]
  s.add_runtime_dependency "rails", ["~> 3.2.0"]
  s.add_runtime_dependency "paper_trail", "~> 2.6.3"

  s.add_development_dependency "sqlite3", "~> 1.3.5"
  s.add_development_dependency "pg", "~> 0.14"
  s.add_development_dependency "mysql2", "~> 0.3"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "debugger", "~> 1.2.0"

end
