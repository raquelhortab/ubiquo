# Loads Rails and fires the worker

if ARGV.empty?
  raise ArgumentError, "A worker name is required as an application option"
end

puts '=> Loading Rails...'

Dir.chdir(File.dirname(__FILE__) + "/../../../../../")
unless Object.const_defined? 'RAILS_ENV'
  require File.dirname(__FILE__) + '/../../../../../config/environment'
end

puts '** Rails loaded.'
puts "** Starting UbiquoWorker..."

UbiquoWorker.init(ARGV[0], ARGV[1])
