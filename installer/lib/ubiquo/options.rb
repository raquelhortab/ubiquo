module Ubiquo
  # TODO: Improve banner to inform of UBIQUO_OPTS env var merging
  # TODO: Add git needed params for repo creation on github
  class Options < Hash

    attr_reader :opts, :orig_args

    def initialize(args)
      @orig_args = args.clone

      self[:template] = :stable
      self[:profile]  = :complete
      self[:locale]   = :en
      self[:devel]    = false
      self[:rvm]      = false
      self[:gem_path] = false
      self[:clone_gems] = false
      self[:database] = :sqlite
      self[:exception_recipient] = "chan@ge.me"
      self[:sender_address] = "chan@ge.me"


      @opts = OptionParser.new do |o|
        o.banner = """Usage: #{File.basename($0)} [options] application_name"
        o.separator "\nSelect a database (defaults to sqlite if not specified):"

        suported_databases.each do |db,msg|
          o.on("--#{db.to_s}", msg) { self[:database] = db }
        end

        o.separator "\nSelect a template (defaults to stable if not specified):"

        suported_templates.each do |tpl, msg|
          o.on("--#{tpl.to_s}", msg) { self[:template] = tpl }
        end

        o.separator "\nSelect a profile (defaults to complete if not specified):"

        suported_profiles.each do |profile, msg|
          o.on("--#{profile.to_s}", msg) { self[:profile] = profile }
        end
        o.on(
          "--custom [PLUGINS]",
          "Includes minimal template, but you can add extra plugins"
        ) do |plugins|
          self[:profile] = :custom
          self[:plugins] = plugins.split(",")
        end

        o.separator "\nSelects ubiquo default locale (defaults to english): "

        suported_locales.each do |locale, msg|
          o.on("--#{locale.to_s}", msg) { self[:locale] = locale }
        end

        o.separator "\nException notification options: "

        o.on("--recipient [EMAIL]", "E-mail for exception notifications.") do |recipient|
          self[:exception_recipient] = recipient
        end

        o.on("--sender [EMAIL]", "E-mail to use in from.") do |sender|
          self[:sender_address] = sender
        end

        o.separator "\nExtra options:"

        o.on("--rvm", 'Create a new rvm gemset named as the project and use it in the bundle install') do
          self[:rvm] = true
        end

        o.on("--gem-path [PATH]", 'Use ubiquo gems that are placed in this path') do |gem_path|
          self[:gem_path] = gem_path
        end

        o.on("--clone-gems", 'Do a git clone of the ubiquo gems in the specified --gem-path') do
          self[:clone_gems] = true
        end

        o.on("--devel", 'For ubiquo developers (ssh acces to github repos)') do
          self[:devel] = true
        end

        o.on("-v", '--version', "Displays this gem version.") do
          self[:version] = File.read(File.dirname(__FILE__) + "/../../VERSION").strip
        end

        o.on_tail('-h', '--help', 'displays this help and exit') do
          self[:show_help] = true
        end

      end

      begin
        @opts.parse!(args)
        self[:app_name] = args.shift
      rescue OptionParser::InvalidOption => e
        self[:invalid_argument] = e.message
      end
    end

    def merge(other)
      self.class.new(@orig_args + other.orig_args)
    end

    private

    def suported_databases
      {
        :postgresql => "Uses postgresql database.",
        :mysql      => "Uses mysql database.",
        :sqlite     => "Uses sqlite database."
      }
    end

    def suported_templates
      {
        :stable => "Follows the latest ubiquo stable branch. Recommended for production.",
        :edge   => "Follows the development branch."
      }
    end

    def suported_profiles
      {
        :minimal  => "Includes minimal set of ubiquo plugins.",
        :complete => "Includes all available ubiquo core plugins."
      }
    end

    def suported_locales
      {
        :ca => "Selects Catalan.",
        :es => "Selects Spanish.",
        :en => "Selects English."
      }
    end

  end
end
