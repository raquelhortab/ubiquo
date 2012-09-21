# -*- encoding: utf-8 -*-
$:.push File.expand_path("../../ubiquo_core/lib", __FILE__)
require "ubiquo/version"

Gem::Specification.new do |s|
  s.name = "ubiquo"
  s.version = Ubiquo.version

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Albert Callarisa", "Jordi Beltran", "Bernat Foj", "Eric Garc\u{ed}a", "Felip Ladr\u{f3}n", "David Lozano", "Antoni Reina", "Ramon Salvad\u{f3}", "Arnau S\u{e1}nchez"]
  s.description = "This gem provides a command-line interface to speed up the creation of ubiquo based apps."
  s.email = "rsalvado@gnuine.com"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.homepage = "http://www.ubiquo.me"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "command line application for building ubiquo based applications."

  s.add_runtime_dependency "rails", "~> 3.2.7"
  s.add_runtime_dependency "bundler", "~> 1.1.5"

  # add all ubiquo gems by default so that it speeds up new app creation
  %w{access_control activity authentication categories core design i18n
      jobs media menus scaffold versions
  }.each do |ubiquo_gem|
#    s.add_runtime_dependency "ubiquo_#{ubiquo_gem}", Ubiquo.version
  end

end

