#
# Class that manages jobs as SQS messages
#
module UbiquoJobs
  module Jobs
    class SQSJob < AWS::SQS::ReceivedMessage
      include UbiquoJobs::Jobs::JobUtils

      attr_accessor :message, :state, :runner, :started_at, :ended_at,
        :result_code, :result_error, :tries, :options

      # Implementation of attribute setter
      def set_property(property, value)
        send("#{property}=", value)
      end

      # Returns the error messages produced by the job execution, if any
      def error_log
        self.result_error
      end

      def initialize options = {}
        options.each_pair { |k,v| set_property k, v}
      end

      # Returns an identifier for the job. As it is used in logs and this will be
      # the only information that can be useful, the id is really a string with
      # the following format: "JobType/SQSMessageId/Body"
      def id
        "#{self.class.name}/#{self.message.id}/#{self.message.body}"
      end

      # Implementation of the method that is called when the job successfully finish
      def notify_finished
        message.delete
      end

      def parse_params
        body = Base64.decode64(message.body)
        Rack::Utils.parse_nested_query(body).with_indifferent_access
      end

      ########### Class Methods ##############

      # Given a message, return a Job instance from the correct class
      # with the message already inside it
      def self.wrap_message_as_job message
        job_info = SQSHandler.get_job_info_by_queue message.queue
        if !job_info
          Rails.logger.error("No job info found for message in queue #{message.queue.url}")
          return
        end
        job_info[:class].constantize.new(:message => message)
      end

      def self.create options = {}
        new(options).tap do |job|
          queue_url = SQSHandler.get_queue_url_by_class(self)
          SQSHandler.conn.send_message :queue_url => queue_url, :message_body => job.body
        end
      end

    end
  end
end
