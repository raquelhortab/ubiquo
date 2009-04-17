require File.dirname(__FILE__) + "/../../../test_helper.rb"
require 'ubiquo_jobs/managers/active_manager'
require 'ubiquo_jobs/jobs/base'

ActiveJob = UbiquoJobs::Jobs::ActiveJob

class UbiquoJobs::Managers::ActiveManagerTest < ActiveSupport::TestCase
  
  def test_should_get_job
    job = create_job
    assert_equal job, ActiveManager.get('me')
  end

  def test_should_not_be_able_to_create_a_nil_priority_job
    assert_raise(ActiveRecord::StatementInvalid) { create_job(:priority => nil) }
  end
  
  def test_should_get_job_higher_priority_first
    job_1 = create_job(:priority => 5)
    job_2 = create_job(:priority => 1)
    job_3 = create_job(:priority => 2)
    assert_equal job_2, ActiveManager.get('me')
    assert_equal job_3, ActiveManager.get('you')
    assert_equal job_1, ActiveManager.get('hi')
  end

  def test_should_not_get_job_until_planified
    create_job(:planified_at => 5.minutes.from_now)
    assert_nil ActiveManager.get('me')
  end
  
  def test_should_not_get_unplanified_job
    create_job(:planified_at => nil)
    assert_nil ActiveManager.get('me')
  end
  
  def test_should_fail_to_run
    create_job
    assert_raise NotImplementedError do
      ActiveManager.get('me').run!
    end
  end
  
  def test_should_recover_from_failure
    short_retry_interval
    old_job = create_job(
      :state => UbiquoJobs::Jobs::Base::STATES[:started],
      :runner => 'me'
    )
    assert_nil ActiveManager.get('me')
    assert_nil old_job.reload.runner
    assert_equal UbiquoJobs::Jobs::Base::STATES[:waiting], old_job.state
    sleep 1
    assert_equal old_job, ActiveManager.get('me')
    
    restore_retry_interval
  end

  def test_should_recover_from_not_started
    short_retry_interval

    job_1 = create_job(:priority => 2)
    assert_equal job_1, ActiveManager.get('me')
    job_2 = create_job(:priority => 1)
    assert_equal job_2, ActiveManager.get('me')
    assert_nil ActiveManager.get('you')
    sleep 1
    assert_equal job_1, ActiveManager.get('you')
    assert_nil ActiveManager.get('him')

    restore_retry_interval
  end
  
  def test_should_add_job
    assert_difference 'ActiveJob.count' do
      ActiveManager.add(ActiveJob, :priority => 1000)
    end
  end

  private

  def create_job(options = {})
    default_options = {
      :priority => 1000, # Default value when using run_async
      :command => 'ls',
      :planified_at => Time.now.utc,
    }
    ActiveJob.create(default_options.merge(options))
  end
  
  def short_retry_interval
    @default_interval = UbiquoJobs::Jobs::Base.retry_interval
    UbiquoJobs::Jobs::Base.retry_interval = 1.second
  end

  def restore_retry_interval
    UbiquoJobs::Jobs::Base.retry_interval = @default_interval
  end
end
