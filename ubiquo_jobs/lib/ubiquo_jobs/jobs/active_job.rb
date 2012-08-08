#
# Class that manages persistency of jobs classes as an ActiveRecord
#
module UbiquoJobs
  module Jobs
    class ActiveJob < ActiveRecord::Base
      include UbiquoJobs::Jobs::JobUtils

      before_create :set_default_state
      before_save :store_options
      after_find :load_options

      has_many :active_job_dependants,
        :foreign_key => 'previous_job_id',
        :class_name => 'UbiquoJobs::Jobs::ActiveJobDependency'

      has_many :active_job_dependencies,
        :foreign_key => 'next_job_id'

      has_many :dependencies,
        :through => :active_job_dependencies,
        :source => :previous_job

      has_many :dependants,
        :through => :active_job_dependants,
        :source => :next_job,
        :dependent => :destroy

      attr_accessor :options

      filtered_search_scopes :text => [:name], :enable => [:date_start, :date_end, :state, :state_not]
      scope :date_start, lambda{ |value|
        where("created_at > ?", value)
      }
      scope :date_end, lambda{ |value|
        where("created_at < ?", value)
      }
      scope :state, lambda{ |value|
        where("state = ?", value)
      }
      scope :state_not, lambda{ |value|
        where("state != ?", value)
      }

      attr_accessible :runner, :command, :tries, :priority, :planified_at,
        :started_at, :ended_at, :result_code, :result_output, :result_error,
        :notify_to, :state, :name, :type, :options

      # Save updated attributes.
      # Optimistic locking is handled automatically by Active Record
      def set_property(property, value)
        update_attributes property => value
      end

      # Returns the outputted results of the job execution, if any
      def output_log
        self.result_output
      end

      # Returns the error messages produced by the job execution, if any
      def error_log
        self.result_error
      end

      # Set a job to be executed (again), giving it a planification time
      # Useful e.g. for a stopped job or a job that has not had a succesful
      # execution (is in error state) but you want a retry.
      def reset!
        update_attributes(
          :runner => nil,
          :state => STATES[:waiting],
          :planified_at => Time.now.utc + Base.retry_interval
        )
      end

      protected

      # Set the waiting state as default
      def set_default_state
        self.state ||= STATES[:waiting]
      end

      # Using the configured notifier, send a "finished job" email,
      # if a receiver has been set in notify_to
      def notify_finished
        UbiquoJobs.notifier.deliver_finished_job self unless notify_to.blank?
      end

      def validate_command
        errors.add_on_blank(:command)
        false unless errors.empty?
      end

      # Store the options hash in the stored_options field, in yaml format
      def store_options
        write_attribute :stored_options, self.options.to_yaml
      end

      # Load the stored options (which are stored in yaml) into the options hash
      def load_options
        begin
          self.options = YAML::load(self.stored_options.to_s)
          # Fix for http://dev.rubyonrails.org/ticket/7537
          self.options.each_pair do |k,v|
            resolve_constant v
          end if self.options
          self.options = YAML::load(self.stored_options.to_s)

        rescue
          update_attributes(
            :state => STATES[:error],
            :result_error => $!.inspect + $!.backtrace.inspect + self.stored_options.to_s
          )
        end
      end

      # Looks for and loads unresolved constants recursively
      def resolve_constant(element)
        unless element.instance_variable_get(:@class).nil?
          element.instance_variable_get(:@class).constantize
        end
        if element.is_a?(Array) || element.is_a?(Hash)
          element.each do |val|
            resolve_constant val
          end
        end
      end

    end
  end
end
