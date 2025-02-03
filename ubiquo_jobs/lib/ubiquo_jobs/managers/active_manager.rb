require 'ubiquo_jobs/jobs/active_job'

module UbiquoJobs
  module Managers
    class ActiveManager < UbiquoJobs::Managers::Base

      # Get the most appropiate job to run, depending job priorities, states
      # dependencies and planification dates
      #
      #   runner: name of the worker that is asking for a job
      #
      def self.get(runner)
        recovery(runner)
        job_class.transaction do
        candidate_jobs = job_class.where('planified_at <= ? AND state = ?',
                                         Time.now.utc,
                                         UbiquoJobs::Jobs::Base::STATES[:waiting]).order(job_order).lock(true)

        job = first_without_dependencies(candidate_jobs)
          result = job.update_attributes({
            :state => UbiquoJobs::Jobs::Base::STATES[:instantiated],
            :runner => runner
          }) if job
          job = nil unless result
        job
      end
      end

      # Get the job instance that has the given job_id
      #
      #   job_id: job identifier
      #
      def self.get_by_id(job_id)
        job_class.find(job_id)
      end

      # Get an array of jobs matching filters
      #
      #   filters: hash of properties that the jobs must fullfill, and/or the following options:
      #     {
      #       :order => list order, sql syntax
      #       :page => number of the asked page, for pagination
      #       :per_page => number per_page job elements (default 10)
      #     }
      #
      # Returns an array with the format [pages_information, list_of_jobs]
      #
      def self.list(filters = {})
        job_class.paginated_filtered_search(filters.reverse_merge(:per_page => 10))
      end

      # TODO: see if this can be merged in recovery
      # Get an already assigned task for a given runner,
      # or nil if that runner does not have any assigned task
      #
      #   runner: name of the worker that is asking for a job
      #
      def self.get_assigned(runner)
        job_class.where("runner = ? AND state NOT IN (?)", runner,
                        [UbiquoJobs::Jobs::Base::STATES[:finished],
                         UbiquoJobs::Jobs::Base::STATES[:error]]).
          order(job_order).first

      end

      # Creates a job using the given options, and planifies it
      # to be run according to the planification options
      #
      #   type: class type of the desired job
      #   options: properties for the new job
      #
      def self.add(type, options = {})
        job = type.new(options, :without_protection => true)
        job.save
        job
      end

      # Deletes a the job that has the given identifier
      # Returns true if successfully deleted, false otherwise
      #
      #   job_id: job identifier
      #
      def self.delete(job_id)
        job_class.find(job_id).destroy
      end

      # Updates the existing job that has the given identifier
      # Returns true if successfully updated, false otherwise
      #
      #   job_id: job identifier
      #   options: a hash with the changed properties
      #
      def self.update(job_id, options)
        job_class.find(job_id).update_attributes(options, :without_protection => true)
      end

      # Marks the job with the given identifier to be repeated
      #
      #   job_id: job identifier
      #
      def self.repeat(job_id)
        job_class.find(job_id).reset!
      end

      # Return the job class that the manager is using, as a constant
      #
      #   type: class type of the desired job
      #   options: properties for the new job
      #
      def self.job_class
        UbiquoJobs::Jobs::ActiveJob
      end

      # Returns the sql order clause for sorting jobs.
      def self.job_order
        'priority asc'
      end

      protected

      # Performs a cleanup (reset) of possible stalled jobs for the asked runner
      def self.recovery(runner)
        job = get_assigned(runner)
        job.reset! if job
      end

      # Given a set of jobs, returns the first one that have all their dependencies satisfied
      def self.first_without_dependencies(candidates)
        candidate_ids = candidates.pluck(:id)
        job_class.where(id: candidate_ids).find_each(batch_size: 300) do |candidate|
          next if candidate.state != UbiquoJobs::Jobs::Base::STATES[:waiting]
          return candidate if candidate.dependencies.inject(true) do |satisfied, job|
            satisfied && job.state == UbiquoJobs::Jobs::Base::STATES[:finished]
          end
        end
        nil
      end

    end
  end
end
