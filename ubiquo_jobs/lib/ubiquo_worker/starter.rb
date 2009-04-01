# Loads Rails and fires the worker

raise ArgumentError, "A worker name is required as an application option" if ARGV.empty?

puts '=> Loading Rails...'

require File.dirname(__FILE__) + '/../../config/environment' unless Object.const_defined? 'RAILS_ENV'

puts '** Rails loaded.'
puts "** Starting UbiquoWorker..."

UbiquoWorker.init(ARGV[0])
