# This class manages the connection to SQS and the different queues that can be used
class UbiquoJobs::SQSHandler

  class << self

    # Returns a ready-to-use SQS connection (an instance of AWS::SQS::Client)
    def conn
      @sqs ||= begin
        AWS.config(:access_key_id => credentials[:access_key_id], :secret_access_key => credentials[:secret_access_key], :use_ssl => true, :logger => nil)
        AWS::SQS.new(:sqs_endpoint => credentials[:endpoint])
      end
    end

    # Returns a hash with the contents of the sqs.yml file
    def config
      @config ||= YAML.load_file("#{Rails.root}/config/sqs.yml").with_indifferent_access
    end

    # Given an AWS::SQS::Queue, return the corresponding job hash from the config
    def get_job_info_by_queue queue
      full_queue_name = queue.url.split('/').last
      # full_queue_name is something like queue_name_ENV
      queue_name = /.*_(.*)$/.match(full_queue_name)[1]
      config[:jobs].select{ |k,v| v[:queue_name] == queue_name }.first.last
    end

    # Given a subclass of UbiquoJobs::Jobs::SQSJob, returns its associated queue url
    def get_queue_url_by_class klass
      job_info = config[:jobs].select{ |k,v| v[:class] == klass.name}.first.last
      create_queue_url job_info[:queue_name]
    end

    # Given a queue_name (e.g. 'createusers'), returns the AWS::SQS::Queue that corresponds to it
    def get_queue_by_queue_name name
      conn.queues[create_queue_url(name)]
    end

    # Given a queue_name, returns the full queue url
    def create_queue_url name
      "https://#{credentials[:endpoint]}/#{credentials[:aws_account_number]}/#{full_queue_name(name)}"
    end

    # Returns the full queue name as created in SQS following the convention
    def full_queue_name name
      "#{name}_#{environment_suffix}"
    end

    # Returns an suffix like 'pre' or 'pro' depending on Rails.env[0,3]
    # If you set a :forced_environment inside your credentials in sqs.yml,
    # it will take preference and be always used
    def environment_suffix
      credentials[:forced_environment] || Rails.env[0,3]
    end

    # Returns a hash with the configured credentials
    def credentials
      config[:credentials]
    end

    # returns an array with [[q1,q2,q3], [p1,p2,p3]] where q's are AWS::SQS::Queue instances
    # and their corresponding p's are an integer representing the priority of each queue
    # (the higher the most priority)
    def queues_and_priorities
      @queues_and_priorities ||= begin
        qp = config[:jobs].map do |k, v|
          queue = get_queue_by_queue_name v[:queue_name]
          priority = v[:priority].nil? ? 1 : v[:priority]
          [queue, priority]
        end
        # qp = [[Q1,P1],[Q2,P2]..]
        [qp.map(&:first), qp.map(&:last)]
      end
    end

    # This method will create, if they don't exists, the needed queues in SQS
    # It's only here as a dev helper, it shouldn't be used in normal code
    def create_queues
      config[:jobs].each do |k, v|
        next if get_queue_by_queue_name(v[:queue_name]).exists?

        queue_name = full_queue_name(v[:queue_name])
        conn.queues.create(queue_name, :visibility_timeout => 60)
      end
    end


  end
end
