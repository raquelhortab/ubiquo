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
    %w(test_sqlite3 test_postgresql test_mysql2)
  run_without_aborting(*tasks)
end

%w( mysql2 postgresql sqlite3 jdbcmysql jdbcpostgresql jdbcsqlite3).each do |adapter|
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  }

  namespace adapter do
    task :test => "test_#{adapter}"

    # Set the connection environment for the adapter
    task(:env) { ENV['ARCONN'] = adapter }
  end

  # Make sure the adapter test evaluates the env setting task
  task "test_#{adapter}" => "#{adapter}:env"
end
