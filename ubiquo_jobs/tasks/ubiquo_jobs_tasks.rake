namespace :ubiquo do
  namespace :worker do
    desc "Starts a new ubiquo worker"
    task :start, :name, :interval, :needs => :environment do |t, args|
      arguments = [args.name, args.interval].compact
      UbiquoWorker.init(*arguments)
    end
  end
end