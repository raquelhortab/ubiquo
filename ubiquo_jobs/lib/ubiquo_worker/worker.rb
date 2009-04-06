module UbiquoWorker

  class Worker
    attr_accessor :name, :shutdown

    def initialize(name) 
      raise ArgumentError, "A worker name is required" if name.blank?
      self.name = name
      self.shutdown = false
    end

    def run!
      while (!shutdown) do
        job = UbiquoJobs.manager.get(name)
        if job
          puts "#{Time.now} - executing job #{job.id}"
          job.run!
        else
          puts "#{Time.now} - no job available"
          sleep 5
        end
      end
    end
        
  end  
end


