module UbiquoWorker

  class Worker
    attr_accessor :name, :sleep_time, :sleep_interval, :pid_file_path, :shutdown

    def initialize(name, options = {})
      raise ArgumentError, "A worker name is required" if name.blank?
      self.name = name
      self.pid_file_path = options[:pid_file_path] || Rails.root + "tmp/pids/#{name}"
      self.sleep_time = options[:sleep_time]
      self.sleep_interval = options[:sleep_interval] || 1.0
      self.shutdown = false
    end

    # This method will start executing the planified jobs.
    # If no job is available, the worker will sleep for sleep_time sec.
    def run!
      daemon_handle_signals
      with_pid_file do
        while (!shutdown) do
          job = UbiquoJobs.manager.get(name)
          if job
            puts "#{Time.now} [#{name}] - executing job #{job.id}"
            job.run!
          else
            puts "#{Time.now} [#{name}] - no job available"
            wait
          end
        end
      end
    end

    private

    def with_pid_file
      raise ArgumentError unless block_given?
      if File.exists? pid_file_path
        puts "Existing pid file: #{pid_file_path}"
        existing_pid = File.read(pid_file_path).to_i
        if existing_pid > 0
          begin
            Process.kill(0, existing_pid)
            abort "Process with pid #{existing_pid} already running. Aborting..."
          rescue Errno::ESRCH
            puts "Process with pid #{existing_pid} not running. Cleaning pid file and continuing..."
            store_pid
          rescue Errno::EPERM
            abort "No permission to query process with id #{existing_pid}. Changed uid, please do investigate. Aborting..."
          end
        else
          abort "pid file doesnt contain an integer?"
        end
      else
        store_pid
      end
      yield
      cleanup_pid_file
    end

    def store_pid
      File.open(pid_file_path, 'w') {|f| f.write(Process.pid) }
    end

    def cleanup_pid_file
      File.delete pid_file_path if File.exists? pid_file_path
    end

    def daemon_handle_signals
      Signal.trap("TERM") do
        puts "Caught TERM signal, terminating ..."
        self.shutdown = true
      end
    end

    def wait
      time_slept = 0
      while time_slept < self.sleep_time
        break if shutdown
        sleep sleep_interval
        time_slept = time_slept + sleep_interval
      end
    end

  end
end


