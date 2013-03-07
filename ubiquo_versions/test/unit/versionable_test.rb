require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::VersionableTest < ActiveSupport::TestCase

  def test_should_set_model_as_versionable
    ar = create_ar
    options = {:max_amount => 3}
    ar.class_eval do
      versionable options
    end
    assert ar.is_versionable?
    assert_equal options, ar.instance_variable_get('@versionable_options')
  end

  def test_should_get_versions
    versionable = create_versionable_model(:my_field => '1')
    assert_equal 1, versionable.versions.size
    versionable.update_attributes :my_field => '2'
    assert_equal 2, versionable.versions.size
    versionable.update_attributes :my_field => '3'
    assert_equal 3, versionable.versions.size
  end

  def test_should_get_versions_count
    versionable = create_versionable_model(:content_id => 2)
    assert_equal 1, versionable.versions.count
  end

  def test_should_not_create_version_if_update_fails
    set_test_model_as_versionable
    versionable = create_versionable_model(:my_field => 'val')
    TestVersionableModel.any_instance.expects(:valid?).returns(false)
    versionable.update_attributes :my_field => 'newval'
    assert_equal 'val', versionable.reload.my_field
    assert_equal 1, versionable.versions.count # only the initial version
  end

  def test_should_leave_untouched_other_current_versions
    set_test_model_as_versionable
    versionable_1 = create_versionable_model(:my_field => 'val')
    versionable_2 = create_versionable_model(:my_field => 'val')

    assert_equal 2, TestVersionableModel.count
    versionable_1.update_attributes :my_field => 'new'
    assert_equal 2, versionable_1.versions.size
    assert_equal 1, versionable_2.versions.size
  end

  def test_should_execute_without_versionable
    set_test_model_as_versionable
    versionable = create_versionable_model
    TestVersionableModel.without_versionable {versionable.update_attributes :my_field => 'value'}
    assert_equal 1, versionable.versions.count
  end

  def test_should_maintain_maximum_number_of_versions
    set_test_model_as_versionable({:max_amount => 3})
    versionable = create_versionable_model
    5.times do |i|
     versionable.update_attributes :my_field => "val#{i}"
     assert versionable.versions.size <= 3
    end
    assert_equal 3, versionable.versions.reload.size
    c = versionable.versions.last.index
    assert_equal [c-2, c-1, c], versionable.versions.map(&:index)
  end

  def test_destroy_should_create_destroyed_version_on_destroy
    set_test_model_as_versionable
    TestVersionableModel.delete_all
    versionable = create_versionable_model
    5.times do |i|
     versionable.update_attributes :my_field => "val#{i}"
    end
    assert_equal 6, Version.count
    versionable.destroy
    assert_equal 7, Version.count
  end

  def test_should_restore_version
    set_test_model_as_versionable
    versionable = create_versionable_model(:my_field => 'val')
    versionable.update_attributes :my_field => 'new'
    old_version = versionable.versions.last

    versionable.restore(old_version.id)
    assert_equal 'val', versionable.reload.my_field
    assert_equal 3, versionable.versions.count
  end

  private

  def create_ar(options = {})
    Class.new(ActiveRecord::Base)
  end

  def create_versionable_model(options = {})
    TestVersionableModel.create(options)
  end

  create_ar_test_backend_for_versionable
end

