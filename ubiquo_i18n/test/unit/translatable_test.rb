require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::TranslatableTest < ActiveSupport::TestCase

  def test_should_save_translatable_attributes_list
    ar = create_ar
    ar.class_eval do
      translatable :my_field, :my_other_field
    end
    [:my_field, :my_other_field].each do |field|
      assert ar.translatable_attributes.include?(field)
    end
  end

  def test_untranslatable_method_reverts_translatable
    ar = create_ar
    ar.class_eval do
      translatable :my_field
      untranslatable
    end
    assert !ar.is_translatable?
    assert ar.translatable_attributes.empty?
  end

  def test_untranslatable_method_maintains_parent_translatable
    ar = create_ar
    ar.class_eval do
      translatable :my_field
    end
    son = Class.new(ar)
    son.class_eval do
      translatable :my_other_field
      untranslatable
    end

    assert ar.is_translatable?
    assert ar.translatable_attributes.include?(:my_field)
  end

  def test_should_accumulate_translatable_attributes_list_from_parent
    ar = create_ar
    ar.class_eval do
      translatable :my_field, :my_other_field
    end
    son = Class.new(ar)
    son.class_eval do
      translatable :field3, :field4
    end
    [:my_field, :my_other_field, :field3, :field4].each do |field|
      assert son.translatable_attributes.include?(field)
    end
    gson = Class.new(son)
    gson.class_eval do
      translatable :field5
    end
    [:my_field, :my_other_field, :field3, :field4, :field5].each do |field|
      assert gson.translatable_attributes.include?(field)
    end
  end

  def test_should_not_set_translatable_timestamps
    ar = create_ar
    ar.class_eval do
      translatable :my_field, :my_other_field, :timestamps => false
    end
    assert !ar.translatable_attributes.include?(:created_at)
    assert !ar.translatable_attributes.include?(:updated_at)
  end

  def test_should_set_translatable_timestamps_by_default
    ar = create_ar
    ar.class_eval do
      translatable
    end
    assert ar.translatable_attributes.include?(:created_at)
    assert ar.translatable_attributes.include?(:updated_at)
  end

  def test_should_have_global_translatable_attributes
    ar = create_ar
    assert_equal_set [:locale, :content_id, :lock_version], ar.global_translatable_attributes
  end

  def test_should_have_empty_default_translatable_scopes
    ar = create_ar
    assert_equal [], ar.translatable_scopes
  end

  def test_should_store_locale
    model = create_model(:my_field => 'ca', :locale => 'ca')
    assert String === model.locale
    assert_equal model.my_field, model.locale
  end

  def test_should_store_string_locale_in_dual_format
    locale = create_locale(:iso_code => 'ca')
    model = create_model(:locale => locale)
    assert_equal 'ca', model.locale
  end

  def test_should_add_content_id_on_create_if_empty
    assert_difference 'TestModel.count' do
      model = create_model
      assert_not_nil model.content_id
    end
  end

  def test_should_not_add_content_id_on_create_if_exists
    assert_difference 'TestModel.count' do
      model = create_model(:content_id => 12)
      assert_equal 12, model.content_id
    end
  end

  def test_should_not_add_current_locale_on_create_if_exists
    assert_difference 'TestModel.count' do
      model = create_model(:locale => 'ca')
      assert_equal 'ca', model.locale
    end
  end

  def test_should_update_non_translatable_attributes_in_instances_sharing_content_id_on_create
    test_1 = create_model(:my_field => 'f1', :my_other_field => 'f2', :locale => 'ca')
    test_2 = create_model(:my_field => 'newf1', :my_other_field => 'newf2', :locale => 'es', :content_id => test_1.content_id)
    create_model(:my_field => 'newerf1', :my_other_field => 'newerf2')
    assert_equal 'newf2', test_1.reload.my_other_field
    assert_equal 'f1', test_1.my_field
    assert_equal 'newf1', test_2.my_field
    assert_equal 'newf2', test_2.my_other_field
  end

  def test_should_update_non_translatable_attributes_in_instances_sharing_content_id_on_update
    ca = create_model(:my_field => 'f1', :my_other_field => 'f2', :locale => 'ca')
    es = create_model(:my_field => 'newf1', :my_other_field => 'newf2', :locale => 'es', :content_id => ca.content_id)
    ca.update_column :my_other_field, 'common'
    ca.save
    assert_equal 'common', es.reload.my_other_field
    es.update_column :my_field, 'mine'
    assert_equal 'f1', ca.reload.my_field
  end

  def test_should_not_update_non_translatable_attributes_if_using_without_updating_translations
    test_1 = create_model(:my_field => 'f1', :my_other_field => 'f2', :locale => 'ca')
    test_2 = create_model(:my_field => 'newf1', :my_other_field => 'newf2', :locale => 'es', :content_id => test_1.content_id)
    test_1.without_updating_translations do
      test_1.update_column :my_other_field, 'common'
    end
    assert_equal 'newf2', test_2.reload.my_other_field
  end

  def test_should_allow_nested_without_updating_translation_calls
    test_1 = create_model(:my_field => 'f1', :my_other_field => 'f2', :locale => 'ca')
    test_2 = create_model(:my_field => 'newf1', :my_other_field => 'newf2', :locale => 'es', :content_id => test_1.content_id)

    test_1.without_updating_translations do
      test_1.without_updating_translations do
        test_1.update_column :my_other_field, 'common1'
      end
      assert_equal 'newf2', test_2.reload.my_other_field

      test_1.update_column :my_other_field, 'common2'
    end
    assert_equal 'newf2', test_2.reload.my_other_field
  end

  def test_should_update_translatable_fields_on_subclasses_with_them_enabled
    in_ca = InheritanceTestModel.create(:my_field => 'ca', :mixed => 'ca', :locale => 'ca')
    in_es = InheritanceTestModel.create(:my_field => 'es', :mixed => 'es', :locale => 'es', :content_id => in_ca.content_id)
    assert_equal 'ca', in_ca.reload.my_field
    assert_equal 'es', in_ca.mixed
    sub_ca = SecondSubclass.create(:my_field => 'ca', :mixed => 'ca', :locale => 'ca')
    sub_es = SecondSubclass.create(:my_field => 'es', :mixed => 'es', :locale => 'es', :content_id => sub_ca.content_id)
    assert_equal 'ca', sub_ca.reload.my_field
    assert_equal 'ca', sub_ca.mixed
  end

  private

  def create_ar(options = {})
    Class.new(ActiveRecord::Base)
  end

  create_test_model_backend

end

