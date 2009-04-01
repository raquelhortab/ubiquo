#This module provides a simple way to create jobs and workers that will execute them
#A _job_ is mainly a command that can be modeled and parameterized by creating new subclasses 
#
#A _worker_ will look for planified jobs and execute them considering the priority. 
#
#== System setup
#To be able to run a worker, you need the following:
#* A Rails app with the database pointing to where the jobs are created and stored.
#* The daemons gem
#
#== Usage example
#
#First, let's create a Job:
#
#  ExampleJob.run_async(:options => options, :planified_at => Time.now.utc)
#
#Please note that all times in Jobs are interpreted as UTC.
#Now, start a worker. Every worker should have a unique id:
#
#  script/ubiquo_worker start -- worker_id
#  
#That's all - The worker will find the job and execute it immediately, since the planification threshold has been overcame
#To stop all the running workers use:
#
#  script/ubiquo_worker stop
#
#TODO: needs review
#== Creating job types
#Creating new job types -and using them instead of the Base Job class- is useful to limit the commands that can be executed, parameterize them, perform validations, etc.
#Basicly you have to override the set_command function to set the command attribute as desired
#You can use virtual attributes to get parameters for set_command
#See ExampleJob for a basic example of job subclassing
#
#== Other features
#* Command result code and output is stored in the DB
#* If a worker is killed while running job, restart it with the same id and the job will be planified again
#* A failing job command (with a result code != 0) will be automatically rerun for 3 times, not necessarily by the same worker, to circumvent potential environment or circumstantial issues. You can set 
#* You can customize this retry interval using Job.retry_interval
#* Use Job::STATES to know the state of a job
#* Jobs will be executed using the priority order (priority => 1 > 2 > 3 etc) 
#* Jobs will not be executed until their planified_at (utc) time 
#
module UbiquoWorker
  
  autoload :Worker, 'ubiquo_worker/worker'

  def self.init(name)
    worker = Worker.new(name)
    worker.run!
  end
end
