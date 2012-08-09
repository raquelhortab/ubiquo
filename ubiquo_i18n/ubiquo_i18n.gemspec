# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ubiquo_i18n/version"

Gem::Specification.new do |s|
  s.name        = "ubiquo_i18n"
  s.version     = UbiquoI18n.version
  s.authors     = ["Jordi Beltran", "Albert Callarisa", "Bernat Foj", "Eric Garcia", "Felip Ladrón", "David Lozano", "Toni Reina", "Ramon Salvadó", "Arnau Sánchez"]
  s.homepage    = "http://www.ubiquo.me"
  s.summary     = %q{Provides an easy, powerful way to internationalize your application, by specifing translatable fields or associations in your models}
  s.description = %q{Provides an easy, powerful way to internationalize your application, by specifing translatable fields or associations in your models}

  s.rubyforge_project = "ubiquo_i18n"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "ubiquo_core", "~> 0.9.0.b1"
  s.add_dependency "routing-filter"
  s.add_development_dependency "sqlite3", "~> 1.3.5"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "pg", "~> 0.14"
  s.add_development_dependency "mysql2", "~> 0.3"
  s.add_development_dependency 'linecache19'
  s.add_development_dependency 'ruby-debug-base19x', '~> 0.11.30.pre4'
  s.add_development_dependency 'ruby-debug19', "~> 0.11.6"

end
