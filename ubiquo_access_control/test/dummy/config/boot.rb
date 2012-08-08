require 'rubygems'
gemfile = File.expand_path('../../../../Gemfile', __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  begin
    Bundler.setup
  rescue Bundler::GitError
    # on fresh checkouts, this error happens because you need to bundle install
    sh('bundle install')

    # looks like there Bundler does not have ATM a clean way to reload,
    # and if you don't reload it, the same error will ocurr even if fixed
    Bundler.send(:remove_instance_variable, :@load)
    Bundler.send(:remove_instance_variable, :@definition)
    Bundler.send(:remove_instance_variable, :@settings)

    Bundler.setup
  end
end

$:.unshift File.expand_path('../../../../lib', __FILE__)