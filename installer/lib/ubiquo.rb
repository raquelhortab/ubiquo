$:.unshift File.dirname(__FILE__)
%w[ rubygems optparse erb tempfile bundler ].each { |f| require f }

module Ubiquo
  autoload :Options, 'ubiquo/options'
  autoload :Generator, 'ubiquo/generator'

  class App
    class << self
      def run!(arguments)
        env_opts = Options.new(ENV['UBIQUO_OPTS'].split(' ')) if ENV['UBIQUO_OPTS']
        options = Options.new(arguments)
        options = options.merge(env_opts) if env_opts

        # We need this because sometimes we upgrade edge but no stable
#        options[:rails] = options[:template] == :edge ? '3.2.0.rc2' : '2.3.14'
#
#        spec = Bundler.load_gemspec(File.expand_path('../ubiquo.gemspec', __FILE__)
#        rails = spec
#
#        unless Gem::Specification::find_by_name('rails', options[:rails])
#          $stderr.puts "Sorry ubiquo --#{options[:template]} needs rails -v=#{options[:rails]} to work properly."
#          options[:show_help] = true
#        end
#
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
        system("rails new #{options[:app_name]} -m #{tpl.path}")
      end
    end
  end
end
