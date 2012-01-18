Ubiquo::Plugin.register(:ubiquo_jobs) do |config|
  config.add :job_manager_class, UbiquoJobs::Managers::ActiveManager
  config.add :job_notifier_class, UbiquoJobs::Helpers::Notifier
end
