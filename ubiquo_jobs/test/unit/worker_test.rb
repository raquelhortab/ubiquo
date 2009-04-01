require File.dirname(__FILE__) + "/../test_helper.rb"
require 'mocha'
require 'daemons'

UBIQUO_TASKS_ROOT = File.dirname(__FILE__) + "/../.."

class WorkerTest < ActiveSupport::TestCase
    
  def test_should_start_daemon
    Daemons.expects(:run).with() {|file, options| file =~ /starter.rb/ && options[:log_output]}
    run_daemon
  end
  
  def test_should_start_worker
    old_argv = ARGV[0]
    ARGV[0] = 'name'
    UbiquoWorker.expects(:init).with('name').returns(nil)
    run_starter
    ARGV[0] = old_argv
  end

  def test_starter_should_be_called_correctly
    assert_raise ArgumentError do
      run_starter(:name => 'start -- ')
    end
  end

  def test_should_build_worker
    UbiquoWorker::Worker.expects(:new)
    start_worker rescue nil
  end

  def test_should_not_build_worker_without_name
    assert_raise ArgumentError do
      start_worker(:name => '')
    end
  end

  def test_should_get_tasks
    UbiquoJobs.manager.expects(:get).with('new_worker')
    start_worker :iterations => 2
  end

  private

  def create_task(options = {})
    default_options = {
      :command => 'ls',
      :planified_at => Time.now.utc,
    }
    Task.create(default_options.merge(options))
  end

  def run_daemon()
    eval File.read(File.join(UBIQUO_TASKS_ROOT, 'script', 'ubiquo_worker'))
  end
  
  def run_starter()
    eval File.read(File.join(UBIQUO_TASKS_ROOT, 'lib', 'ubiquo_worker', 'starter.rb'))
  end

  def start_worker(options = {})
    options = {
      :name => 'new_worker',
      :iterations => 0
    }.merge(options)
    shutdown_values = ([false]*(options[:iterations] > 1 ? options[:iterations]-1 : 0)) << true

    UbiquoWorker::Worker.any_instance.expects(:sleep).times(0..options[:iterations]).returns(nil)
    UbiquoWorker::Worker.any_instance.expects(:shutdown).times(options[:iterations]).returns(*shutdown_values)

    orig_stdout = $stdout
    $stdout = File.new('/dev/null', 'w')
    UbiquoWorker.init(options[:name])
    $stdout = orig_stdout
  end
  
end