# -*- coding: utf-8 -*-
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ubiquo"
    gem.summary = %Q{command line application for building ubiquo based applications.}
    gem.description = %Q{This gem provides a command-line interface to speed up the creation of ubiquo based apps.}
    gem.email = "rsalvado@gnuine.com"
    gem.homepage = "http://www.ubiquo.me"
    gem.authors = [
      "Albert Callarisa",
      "Jordi Beltran",
      "Bernat Foj",
      "Eric García",
      "Felip Ladrón",
      "David Lozano",
      "Antoni Reina",
      "Ramon Salvadó",
      "Arnau Sánchez"
    ]
    # journey dependency: temporal due to dependencies issue:
    # http://weblog.rubyonrails.org/2012/1/4/rails-3-2-0-rc2-has-been-released#comment-29814
    gem.add_dependency(%q<journey>, '= 1.0.0.rc1')
    gem.add_dependency(%q<rails>, '~> 3.2.0.rc2')
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

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ubiquo #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
