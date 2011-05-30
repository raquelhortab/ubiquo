namespace :ubiquo do
  namespace :worker do
    desc "Starts a new ubiquo worker"
    task :start, [:name, :interval] => [:environment] do |t, args|
      options = {
        :sleep_time => args.interval.to_f
      }.delete_if { |k,v| v.blank? }
      UbiquoWorker.init(args.name, options)
    end
  end
end