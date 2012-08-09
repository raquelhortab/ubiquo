# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ubiquo_access_control/version"

Gem::Specification.new do |s|
  s.name        = "ubiquo_access_control"
  s.version     = UbiquoAccessControl.version
  s.authors     = ["Jordi Beltran", "Albert Callarisa", "Bernat Foj", "Eric Garcia", "Felip Ladrón", "David Lozano", "Toni Reina", "Ramon Salvadó", "Arnau Sánchez"]
  s.homepage    = "http://www.ubiquo.me"
  s.summary     = %q{This plugin provides a default access control mechanism for Ubiquo}
  s.description = %q{This plugin provides a default access control mechanism for Ubiquo. Enables your app to use roles and permissions in views and controllers, so you can decide which users have access to which parts or actions of your application.}

  s.rubyforge_project = "ubiquo_access_control"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "ubiquo_core", ["~> 0.9.0.b1"]
  s.add_development_dependency "sqlite3", "~> 1.3.5"
  s.add_development_dependency "pg", "~> 0.14"
  s.add_development_dependency "mysql2", "~> 0.3"
  s.add_development_dependency "mocha", "~> 0.10.0"
  s.add_development_dependency "debugger", "~> 1.2.0"

end
