require 'test_helper'

class UbiquoJobs::Examples::ExampleJobTest < ActiveSupport::TestCase
  def test_should_create_example_job
    assert create_example_job
  end
  
  def test_should_run_example_job
    create_example_job
    job = UbiquoJobs.manager.get('me')
    job.run!
    assert_equal [1,2].size, job.result_output
    assert_equal UbiquoJobs::Jobs::Base::STATES[:finished], job.state
  end

  def test_should_run_example_job_with_exception
    create_example_job_with_exception :tries => 2
    job = UbiquoJobs.manager.get('me')
    job.run!
    assert_equal UbiquoJobs::Jobs::Base::STATES[:error], job.state
  end

  def test_should_run_example_job_without_return
    create_example_job_without_return
    job = UbiquoJobs.manager.get('me')
    job.run!
    assert_equal [1,2].size, job.result_output
    assert_equal UbiquoJobs::Jobs::Base::STATES[:finished], job.state
  end

  private

  def create_example_job(options = {})
    default_options = {
      :options => {:set => [1,2]},
      :planified_at => Time.now.utc,
    }
    UbiquoJobs::Examples::ExampleJob.run_async(default_options.merge(options))
  end
  def create_example_job_with_exception(options = {})
    default_options = {
      :options => {:set => [1,2]},
      :planified_at => Time.now.utc,
    }
    UbiquoJobs::Examples::ExampleJobWithException.run_async(default_options.merge(options))
  end
  def create_example_job_without_return(options = {})
    default_options = {
      :options => {:set => [1,2]},
      :planified_at => Time.now.utc,
    }
    UbiquoJobs::Examples::ExampleJobWithoutReturn.run_async(default_options.merge(options))
  end

end
