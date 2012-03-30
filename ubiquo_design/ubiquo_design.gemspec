# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "ubiquo_design/version"

Gem::Specification.new do |s|
  s.name        = "ubiquo_design"
  s.version     = UbiquoDesign.version
  s.authors     = ["Jordi Beltran",
                   "Albert Callarisa",
                   "Bernat Foj",
                   "Eric Garcia",
                   "Juan Hernández",
                   "Felip Ladrón",
                   "David Lozano",
                   "Toni Reina",
                   "Ramon Salvadó",
                   "Arnau Sánchez"]
  s.homepage    = "http://www.ubiquo.me"
  s.summary     = %q{This gem adds an interface for page creation and layout page design to Ubiquo}
  s.description = %q{This gem adds an interface for page creation and layout page design to Ubiquo}

  s.rubyforge_project = "ubiquo_design"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "ubiquo_core", "~> 0.9.0.b1"
  s.add_development_dependency "sqlite3", "~> 1.3.5"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "memcache"

end
