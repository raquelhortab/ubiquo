#This module provides a simple way to create jobs and workers that will execute them
#A _job_ is mainly a piece of work that usually require some time and is not suitable
# for synchronous execution, and that can be modeled and parameterized by creating new subclasses 
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
#== Creating job types
#For every different kind of work that needs to be done you need to create a new job type. You can then parameterize the options, perform validations, etc.
#Basicly you have to override the do_job_work function and place there the work that will be performed when the worker starts the job
#You can use virtual attributes to get parameters for do_job_work, but every thing that is not stored in the options hash will likely be lost at runtime, since only the options hash has the persistence guaranteed.
#See ExampleJob for a very basic example of a job type subclass
#
#== Other features
#* Use ShellJob to easily wrap commands in jobs and store the command result code and output in the DB
#* You can specify dependencies between jobs (X will not be run before Y and Z are done, etc)
#* If a worker is killed while running job, restart it with the same id and the job will be planified again
#* A failing job command (with a result code != 0) will be automatically rerun for 3 times, not necessarily by the same worker, to circumvent potential environment or circumstantial issues.
#* You can customize this retry interval using Job.retry_interval
#* Use UbiquoJobs::Jobs::Base::STATES to know the state of a job
#* Jobs will be executed using the priority order (priority => 1 > 2 > 3 etc) 
#* Jobs will not be executed until their planified_at (utc) time 
#
module UbiquoWorker
  
  autoload :Worker, 'ubiquo_worker/worker'

  def self.init(name, sleep_time = 5.0)
    worker = Worker.new(name, sleep_time)
    worker.run!
  end
end
