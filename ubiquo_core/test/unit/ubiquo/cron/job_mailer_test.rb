require File.dirname(__FILE__) + "/../../../test_helper.rb"

class Ubiquo::Cron::JobMailerTest < ActionMailer::TestCase

  test "Job error notification" do
    app_name = Ubiquo::Settings.get(:app_name)
    job = 'mailer_test'
    execution_message = 'execution_message'
    error_message = 'error_message'

    @expected.from = Ubiquo::Settings.get(:notifier_email_from)
    @expected.to = 'receiver@test.com'
    @expected.subject = "[#{app_name} #{Rails.env} CRON JOB ERROR] for job: #{job}"

    mail = JobMailer.error(@expected.to, job, execution_message, error_message)
    assert_equal @expected.from, mail.from
    assert_equal @expected.to, mail.to
    assert_equal @expected.subject, mail.subject
    assert_match /#{job}/, mail.encoded
    assert_match /#{app_name}/, mail.encoded
    assert_match /#{execution_message}/, mail.encoded
    assert_match /#{error_message}/, mail.encoded
  end

end
