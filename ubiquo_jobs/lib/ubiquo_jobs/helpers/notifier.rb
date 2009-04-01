module UbiquoJobs
  module Helpers
    class Notifier
  
      def finished_task(task)
        raise NotImplementedError.new("Implement finished_task(task) in your JobNotifier subclass")
      end

    end
  end
end
