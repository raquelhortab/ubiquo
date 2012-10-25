require 'ubiquo'

module UbiquoJobs
  class Engine < Rails::Engine
    include Ubiquo::Engine::Base

    initializer :load_extensions do
      require 'ubiquo_jobs/extensions.rb'
    end

    initializer :register_ubiquo_plugin do
      require 'ubiquo_jobs/init_settings.rb'
    end
    
    initializer :ubiquo_assets_precompile do |app|
      app.config.assets.precompile += %w(ubiquo/ubiquo_jobs.*)
    end
  end

  # Return the manager class to use. You can override the default by setting
  # the :job_manager_class in ubiquo config:
  #   Ubiquo::Settings.context(:ubiquo_jobs).set(
  #     :job_manager_class,
  #     UbiquoJobs::Managers::ActiveManager
  #   )
  def self.manager
    Ubiquo::Settings.context(:ubiquo_jobs).get(:job_manager_class)
  end

  # Return the notifier class to use. You can override the default by using
  # the :job_notifier_class in ubiquo config:
  #   Ubiquo::Settings.context(:ubiquo_jobs).set(
  #     :job_notifier_class,
  #     UbiquoJobs::Helpers::Notifier
  #   )
  def self.notifier
    Ubiquo::Settings.context(:ubiquo_jobs).get(:job_notifier_class)
  end
end
