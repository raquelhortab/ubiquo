# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ubiquo/version"

Gem::Specification.new do |s|
  s.name        = "ubiquo_core"
  s.version     = Ubiquo.version
  s.authors     = ["Jordi Beltran", "Albert Callarisa", "Bernat Foj", "Eric Garcia", "Felip Ladrón", "David Lozano", "Toni Reina", "Ramon Salvadó", "Arnau Sánchez"]
  s.homepage    = "http://www.ubiquo.me"
  s.summary     = %q{Core gem of the ubiquo cms framework}
  s.description = %q{Provides the basic common Ubiquo infrastructure so that other plugins can be built on top of it}

  s.rubyforge_project = "ubiquo_core"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rails", ["~> 3.2.0"]
  s.add_runtime_dependency "prototype-rails", ["~> 3.2.0"]
  s.add_runtime_dependency "jquery-rails", ["~> 2.0.2"]
  s.add_runtime_dependency "paperclip", ["~> 3.0"]
  s.add_runtime_dependency "calendar_date_select"
  s.add_runtime_dependency "tinymce-rails"
  s.add_runtime_dependency "tinymce-rails-langs"
  s.add_runtime_dependency "nanoboy", ["~> 1.0.0"]

  s.add_development_dependency "mocha", "~> 0.10"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "pg", "~> 0.14"
  s.add_development_dependency "mysql2", "~> 0.3"
  s.add_development_dependency "debugger", "~> 1.2.0"

end
