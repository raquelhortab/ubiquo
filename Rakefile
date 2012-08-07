require 'rake'
require 'rake/testtask'

PROJECTS = Dir.glob('*').select{|f| File.directory?(f) && File.exists?(File.join(f, 'Rakefile'))}

desc 'Run all tests by default'
task :default => %w(test)

%w(test).each do |task_name|
  desc "Run #{task_name} task for all projects"
  task task_name do
    errors = []
    PROJECTS.each do |project|
      puts "\n******** Running tests in #{project} ***********\n\n"
      system(%(cd #{project} && #{$0} #{task_name})) || errors << project
    end
    fail("Errors in #{errors.join(', ')}") unless errors.empty?
  end
end
