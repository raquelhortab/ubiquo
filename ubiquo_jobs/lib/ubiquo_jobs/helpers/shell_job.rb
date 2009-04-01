#
# Module to be included to simplify creation of jobs that execute a command
# The command to execute is stored in the 'command' field.
# Each Job implementation that wants to enable ShellJob
# has therefore to allocate this 'command' accessor
# 
module UbiquoJobs
  module Helpers
    module ShellJob
        
      # On creation, set and validate the command
      def initialize(*args)
        super(*args)
        set_command
        validate_command
      end

      protected
      
    
      def do_job_work
        before_execution if self.respond_to?(:before_execution)
        output = %x{#{command}}
        self.update_attribute :result_output, output
        after_execution if self.respond_to?(:after_execution)
        $?
      end
  
      def set_command
        raise NotImplementedError.new("Implement set_command() in your Job subclass") unless command
      end

      def validate_command
        errors.add_on_blank(:command)
        false unless errors.empty?
      end
  
      # Escapes a string to make it safe to use as a command line parameter
      # Based on Ruby's 1.8.7 Shellwords::shellescape method 
      def escape_sh(param)
        param.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
      end

    end
  end
end