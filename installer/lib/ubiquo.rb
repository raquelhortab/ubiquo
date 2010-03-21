$:.unshift File.dirname(__FILE__)
%w[ rubygems optparse ].each { |f| require f }

module Ubiquo
  autoload :Options, 'ubiquo/options'
  autoload :Generator, 'ubiquo/generator'
  
  class App
    class << self
      def run!(arguments)
        env_opts = Options.new(ENV['UBIQUO_OPTS'].split(' ')) if ENV['UBIQUO_OPTS']
        options = Options.new(arguments)
        options = options.merge(env_opts) if env_opts

        if options[:invalid_argument]
          $stderr.puts options[:invalid_argument]
          options[:show_help] = true
        end

        if options[:show_help]
          $stderr.puts options.opts
          return 1
        end
        
        if options[:app_name].nil? || options[:app_name].squeeze.strip == ""
          $stderr.puts options.opts
          return 1
        end
      end

      # TODO: finish checking git pre-requisites (version must support submodules)
      def git?
        git =  `which git`.strip
        `#{git} version | cut -d ' ' -f 3`.strip unless git == ""
      end
    end
  end
end
