module UbiquoJobs
  module Managers
    # This class is an implementation of an UbiquoJobs::Manager using the Amazon
    # AWS SQS service.
    # Note that this class does not implement all the interfaced methods, since
    # it is not currently expected to have a web interface, and some methods therefore
    # are not required
    class SqsManager < UbiquoJobs::Managers::Base

      # List of the queues to be polled in the current iteration
      cattr_accessor :current_queues

      # Get the most appropiate job to run, depending on queue priorities
      #
      #   runner: name of the worker that is asking for a job
      #
      def self.get(runner)

        # Generate a weighted randomized list of queues to be polled
        generate_queues

        # loop the set of queues until one returns a message
        while queue = retrieve_queue
          message = queue.receive_message
          break if message
        end

        if message
          job_class.wrap_message_as_job(message).tap do |job|
            # Set properties as expected to be ubiquojobs-compliant
            job.set_property :state, UbiquoJobs::Jobs::Base::STATES[:instantiated]
            job.set_property :runner, runner
            job.set_property :tries, 0
          end
        end
      end

      # Creates a job using the given options, and planifies it
      # to be run according to the planification options
      #
      #   type: class type of the desired job
      #   options: properties for the new job
      #
      def self.add(type, options = {})
        type.create(options)
      end

      # Return the job class that the manager is using, as a constant
      #
      #   type: class type of the desired job
      #   options: properties for the new job
      #
      def self.job_class
        UbiquoJobs::Jobs::SQSJob
      end

      protected

      # Returns the first queue that should be polled for messages
      def self.retrieve_queue
        self.current_queues.shift
      end

      # Generate a weighted randomized list of queues to be polled
      def self.generate_queues
        qps = SQSHandler.queues_and_priorities
        self.current_queues = qps.first.randomize(qps.last)
      end

    end
  end
end