module UbiquoWorker
  
  autoload :Worker, 'ubiquo_worker/worker'

  def self.init(name, sleep_time = 5.0)
    worker = Worker.new(name, sleep_time)
    worker.run!
  end
end
