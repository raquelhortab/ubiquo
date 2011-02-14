# -*- coding: utf-8 -*-
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ubiquo"
    gem.summary = %Q{command line application for building ubiquo based applications.}
    gem.description = %Q{This gem provides a command-line interface to speed up creation of ubiquo based apps.}
    gem.email = "rsalvado@gnuine.com"
    gem.homepage = "http://www.ubiquo.me"
    gem.authors = [
                   "Albert Callarisa",
                   "Bernat Foj",
                   "Eric García",
                   "Felip Ladrón",
                   "Antoni Reina",
                   "Ramon Salvadó",
                   "Arnau Sánchez"
                  ]
    gem.add_dependency(%q<rails>, '= 2.3.11')
    gem.add_dependency(%q<i18n>, '< 0.5.0')
    gem.add_dependency(%q<lockfile>, '>= 1.4.3')

    gem.add_development_dependency(%q<mocha>, '>= 0.9.8')
    gem.add_development_dependency(%q<highline>, '>= 1.5.2')
    gem.add_development_dependency(%q<ya2yaml>, '>= 0.26')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ubiquo #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
