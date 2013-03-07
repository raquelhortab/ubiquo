require 'rake/testtask'

def run_without_aborting(*tasks)
  errors = []

  tasks.each do |task|
    begin
      puts "\n*********** Running #{task} ************\n\n"
      Rake::Task[task].invoke
    rescue Exception
      errors << task
    end
  end

  abort "Errors running #{errors.join(', ')}" if errors.any?
end

desc 'Default: run unit tests (w postgresql, mysql2 and sqlite).'
task :default => :test

desc 'Run mysql2, sqlite, and postgresql tests'
task :test do
  tasks = defined?(JRUBY_VERSION) ?
    %w(test_jdbcmysql test_jdbcsqlite3 test_jdbcpostgresql) :
    %w(test_mysql2)
  run_without_aborting(*tasks)
end

namespace :db do
  task :create => ['mysql:build_databases', 'postgresql:build_databases']
  task :drop => ['mysql:drop_databases', 'postgresql:drop_databases']
end

%w( mysql2 postgresql sqlite3 jdbcmysql jdbcpostgresql jdbcsqlite3).each do |adapter|
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
    #t.warning = true
    t.verbose = true
  }

  namespace adapter do
    task :test => "test_#{adapter}"

    # Set the connection environment for the adapter
    task(:env) { ENV['ARCONN'] = adapter }
  end

  # Make sure the adapter test evaluates the env setting task
  task "test_#{adapter}" => "#{adapter}:env"
  task "test_#{adapter}" => "db:drop"
  task "test_#{adapter}" => "db:create"
end


namespace :mysql do
  desc 'Build the MySQL test databases'
  task :build_databases do
    %x( mysql -e "create DATABASE #{ENV['UGEM']}_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci ")
  end

  desc 'Drop the MySQL test databases'
  task :drop_databases do
    %x( mysqladmin -f -s drop #{ENV['UGEM']}_test &> /dev/null ; true )
  end

  desc 'Rebuild the MySQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

task :build_mysql_databases => 'mysql:build_databases'
task :drop_mysql_databases => 'mysql:drop_databases'
task :rebuild_mysql_databases => 'mysql:rebuild_databases'


namespace :postgresql do
  desc 'Build the PostgreSQL test databases'
  task :build_databases do
    %x( createdb -E UTF8 -T template0 #{ENV['UGEM']}_test )
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop_databases do
    %x( dropdb #{ENV['UGEM']}_test &> /dev/null; true )
  end

  desc 'Rebuild the PostgreSQL test databases'
  task :rebuild_databases => [:drop_databases, :build_databases]
end

task :build_postgresql_databases => 'postgresql:build_databases'
task :drop_postgresql_databases => 'postgresql:drop_databases'
task :rebuild_postgresql_databases => 'postgresql:rebuild_databases'


