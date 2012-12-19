namespace :ubiquo do
  namespace :sqs_worker do

    desc "Starts a new ubiquo sqs worker"
    task :start, [:name, :interval] => [:environment] do |t, args|

      options = {
        :sleep_time => args.interval.to_f
      }.delete_if { |k,v| v.blank? }

      Ubiquo::Settings.context(:ubiquo_jobs).set(:job_manager_class, UbiquoJobs::Managers::SqsManager)
      UbiquoWorker.init(args.name, options)
    end

    desc "Stops an existing ubiquo sqs worker"
    task :stop, [:name] => [:environment] do |t, args|
      pid = File.read(Rails.root + "tmp/pids/#{args.name}").to_i
      Process.kill("TERM", pid)
    end
  end
end
