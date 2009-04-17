#
# Class that manages persistency of jobs classes as an ActiveRecord
# 
module UbiquoJobs
  module Jobs
    class ActiveJob < ActiveRecord::Base
      include UbiquoJobs::Jobs::JobUtils

      before_create :set_default_state
      before_save :store_options
  
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
    
      # Save updated attributes. 
      # Optimistic locking is handled automatically by Active Record
      def set_property(property, value)
        update_attribute property, value
      end
      
      def output_log
        self.result_output
      end
    
      def error_log
        self.result_error
      end
    
      def self.filtered_search(filters = {}, options = {})
      
        scopes = create_scopes(filters) do |filter, value|
          case filter
          when :text
            {:conditions => ["upper(name) LIKE upper(?)", "%#{value}%"]}
          when :date_start
            {:conditions => ["created_at > ?", "#{value}"]}
          when :date_end
            {:conditions => ["created_at < ?", "#{value}"]}
          when :state
            {:conditions => ["state = ?", value]}
          when :state_not
            {:conditions => ["state != ?", value]}
          end
        end
    
        apply_find_scopes(scopes) do
          find(:all, options)
        end
      end

      def reset!
        update_attributes(
          :runner => nil, 
          :state => STATES[:waiting], 
          :planified_at => Time.now.utc + Base.retry_interval
        )
      end
  
      protected
    
      def set_default_state
        self.state ||= STATES[:waiting]
      end
      
      def notify_finished
        UbiquoJobs.notifier.deliver_finished_job self unless notify_to.blank?
      end
  
      def validate_command
        errors.add_on_blank(:command)
        false unless errors.empty?
      end
    
      def store_options
        write_attribute :stored_options, self.options.to_yaml
      end
    
      def after_find
        self.options = YAML::load(self.stored_options.to_s)
      end
    end
  end
end
