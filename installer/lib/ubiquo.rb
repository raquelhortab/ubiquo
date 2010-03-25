$:.unshift File.dirname(__FILE__)
%w[ rubygems optparse erb tempfile ].each { |f| require f }

module Ubiquo
  autoload :Options, 'ubiquo/options'
  autoload :Generator, 'ubiquo/generator'
  
  class App
    class << self
      def run!(arguments)
        env_opts = Options.new(ENV['UBIQUO_OPTS'].split(' ')) if ENV['UBIQUO_OPTS']
        options = Options.new(arguments)
        options = options.merge(env_opts) if env_opts

        if `rails -v`.strip != "Rails 2.3.5"
          $stderr.puts "Sorry ubiquo needs rails 2.3.5 to work properly."
          options[:show_help] = true
        end
        
        if `which git` == ''
          $stderr.puts "Sorry you need to install git (> 1.5.3). See http://git-scm.com/"
          options[:show_help] = true
        end

        if options[:version]
          $stdout.puts options[:version]
          return 0
        end
        
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

        
        skeleton = File.dirname(__FILE__) + "/ubiquo/template.erb"
        tpl = Tempfile.new('tmp')
        File.open(tpl.path, 'w') do |file|
          file.write Generator.build_template(options, skeleton) 
        end
        tpl.sync=true
        system("rails -m #{tpl.path} #{options[:app_name]}")
      end
    end
  end
end
