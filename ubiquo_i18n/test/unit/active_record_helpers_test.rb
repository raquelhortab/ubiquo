# encoding: utf-8

require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::ActiveRecordHelpersTest < ActiveSupport::TestCase

  def setup
    Locale.current = Locale.default
  end

  def test_simple_filter
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    assert_equal 1, TestModel.locale('es').size
    assert_equal 'es', TestModel.locale('es').first.locale
  end

  def test_many_contents
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 2, :locale => 'es')
    assert_equal 2, TestModel.locale('es').size
    assert_equal %w{es es}, TestModel.locale('es').map(&:locale)
  end

  def test_many_locales_many_contents
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')

    assert_equal 2, TestModel.locale('es').size
    assert_equal 1, TestModel.locale('ca').size
    assert_equal 2, TestModel.locale('ca', 'es').size
    assert_equal %w{ca es}, TestModel.locale('ca', 'es').map(&:locale)
  end

  def test_search_all_locales_sorted
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')

    assert_equal %w{ca es}, TestModel.locale('ca', :all).map(&:locale)
    assert_equal %w{es en}, TestModel.locale('en', :all).map(&:locale)
    assert_equal %w{es es}, TestModel.locale('es', :all).map(&:locale)
    assert_equal %w{ca en}, TestModel.locale('ca', 'en', :all).map(&:locale)

    # :all position is indifferent
    assert_equal %w{es en}, TestModel.locale(:all, 'en').map(&:locale)
  end

  def test_search_with_chained_locale_call
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 2, :locale => 'ca')
    create_model(:content_id => 3, :locale => 'en')

    assert_equal %w{ca}, TestModel.locale('en','es', :all).locale('es','ca').locale('ca').map(&:locale)
    assert_equal %w{ca}, TestModel.locale('ca').locale('en','es', :all).map(&:locale)
    assert_equal %w{ca}, TestModel.locale('ca').locale(:all).locale(:all).map(&:locale)
    assert_equal %w{}, TestModel.locale('ca').locale(:all).locale('en').map(&:locale)
    assert_equal %w{}, TestModel.locale('es').locale('ca').map(&:locale)
  end

  def test_search_with_indirect_chained_locale_call
    create_model(:content_id => 1, :locale => 'es')
    assert_equal [], TestModel.locale('es').paginated_filtered_search('filter_locale' => 'ca').last
  end

  def test_search_by_content
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')

    assert_equal %w{es ca}, TestModel.content(1).all(:order => "id").map(&:locale)
    assert_equal %w{es ca es en}, TestModel.content(1, 2).map(&:locale)
  end

  def test_search_by_content_and_locale
    create_model(:content_id => 1, :locale => 'es')
    create_model(:content_id => 1, :locale => 'ca')
    create_model(:content_id => 2, :locale => 'es')
    create_model(:content_id => 2, :locale => 'en')

    assert_equal %w{es}, TestModel.locale('es').content(1).map(&:locale)
    assert_equal_set %w{ca en}, TestModel.content(1, 2).locale('ca', 'en').map(&:locale)
    assert_equal_set %w{ca es}, TestModel.content(1, 2).locale('ca', 'es').map(&:locale)
    assert_equal %w{}, TestModel.content(1).locale('en').map(&:locale)
  end

  def test_search_by_locale_with_translatable_different_values_default_mode
    create_model(:content_id => 1, :my_field => '1', :locale => 'es')
    create_model(:content_id => 1, :my_field => '2', :locale => 'en')

    assert_equal %w{}, TestModel.locale('es').all(:conditions => {:my_field => '2'}).map(&:locale)
    assert_equal %w{en}, TestModel.locale('es', :all).all(:conditions => {:my_field => '2'}).map(&:locale)
  end

  def test_search_by_locale_with_translatable_different_values_and_search_in_translations
    create_model(:content_id => 1, :my_field => '1', :locale => 'es')
    create_model(:content_id => 1, :my_field => '2', :locale => 'en')

    assert_equal %w{es}, TestModel.locale('es', :mode => :mixed).all(:conditions => {:my_field => '2'}).map(&:locale)
    assert_equal %w{es}, TestModel.locale('es', :all, :mode => :mixed).all(:conditions => {:my_field => '2'}).map(&:locale)
  end

  def test_search_by_locale_with_translatable_different_values_and_without_search_in_translations
    create_model(:content_id => 1, :my_field => '1', :locale => 'es')
    create_model(:content_id => 1, :my_field => '2', :locale => 'en')

    assert_equal %w{}, TestModel.locale('es', :mode => :strict).all(:conditions => {:my_field => '2'}).map(&:locale)
    assert_equal %w{en}, TestModel.locale('es', :all, :mode => :strict).all(:conditions => {:my_field => '2'}).map(&:locale)
  end

  def test_search_by_locale_with_find_scope_and_without_search_in_translations
    create_model(:content_id => 1, :my_field => '1', :locale => 'es')
    create_model(:content_id => 1, :my_field => '2', :locale => 'en')

    assert_equal 1, TestModel.my_field_is_1.size
    assert_equal [], TestModel.my_field_is_1.locale('en', :mode => :strict)
    assert_equal 1, TestModel.my_field_is_1.locale('es', :mode => :strict).size
    assert_equal 1, TestModel.my_field_is_2.size
    assert_equal [], TestModel.my_field_is_2.locale('es', :mode => :strict)
    assert_equal 1, TestModel.my_field_is_2.locale('en', :mode => :strict).size

    one = TestModel.my_field_is_1.locale('en', :all, :mode => :strict)
    assert_equal 1, one.size
    assert_equal 'es', one.first.locale
    two = TestModel.my_field_is_2.locale('es', :all, :mode => :strict)
    assert_equal 1, two.size
    assert_equal 'en', two.first.locale
  end

  def test_search_by_locale_with_find_scope_and_with_search_in_translations
    es = create_model(:content_id => 1, :my_field => '1', :locale => 'es')
    en = create_model(:content_id => 1, :my_field => '2', :locale => 'en')

    assert_equal 1, TestModel.my_field_is_1.size
    assert_equal [en], TestModel.my_field_is_1.locale('en', :mode => :mixed)
    assert_equal 1, TestModel.my_field_is_1.locale('es', :mode => :mixed).size
    assert_equal 1, TestModel.my_field_is_2.size
    assert_equal [es], TestModel.my_field_is_2.locale('es', :mode => :mixed)
    assert_equal 1, TestModel.my_field_is_2.locale('en', :mode => :mixed).size

    one = TestModel.my_field_is_1.locale('en', :all, :mode => :mixed)
    assert_equal 1, one.size
    assert_equal 'en', one.first.locale
    two = TestModel.my_field_is_2.locale('es', :all, :mode => :mixed)
    assert_equal 1, two.size
    assert_equal 'es', two.first.locale
  end

  def test_search_by_locale_with_find_scope_default_mode
    es = create_model(:content_id => 1, :my_field => '1', :locale => 'es')
    en = create_model(:content_id => 1, :my_field => '2', :locale => 'en')

    assert_equal 1, TestModel.my_field_is_1.size
    assert_equal [], TestModel.my_field_is_1.locale('en')
    assert_equal 1, TestModel.my_field_is_1.locale('es').size
    assert_equal [es], TestModel.my_field_is_1.locale('es')
    assert_equal 0, TestModel.my_field_is_1.locale('en').size
    assert_equal 1, TestModel.my_field_is_2.size
    assert_equal [], TestModel.my_field_is_2.locale('es')
    assert_equal 1, TestModel.my_field_is_2.locale('en').size
    assert_equal [en], TestModel.my_field_is_2.locale('en')

    one = TestModel.my_field_is_1.locale('en', :all)
    assert_equal 1, one.size
    assert_equal 'es', one.first.locale
    two = TestModel.my_field_is_2.locale('es', :all)
    assert_equal 1, two.size
    assert_equal 'en', two.first.locale
  end

  def test_search_by_locale_with_virtual_shared_translations
    es = create_model(:my_field => '1', :locale => 'es')
    en = create_model(:content_id => es.content_id, :my_field => '2', :locale => 'en')
    child = create_model(:locale => 'es', :test_model => es)
    assert_equal [child], en.test_models # precondition: shared translations works

    # test_models_test_models is the alias that Rails creates due to the join
    find_parent = ['test_models_test_models.test_model_id = ?', es.id]
    options = {:conditions => find_parent, :joins => :test_models}

    assert_equal [en], TestModel.locale('en', :all).all(options)
    assert_equal [en], TestModel.locale('en').all(options)

    assert_equal [], TestModel.locale('ca').all(options)
    assert_equal [en], TestModel.locale('ca', 'en').all(options)
    assert_equal [en], TestModel.locale('ca', 'en', :all).all(options)

    fallback = TestModel.locale('ca', :all).all(options)
    assert %w{es en}.include?(fallback.first.locale)
  end

  def test_search_by_locale_with_virtual_shared_translations_and_other_conditions
    es = create_model(:my_field => '1', :locale => 'es')
    en = create_model(:content_id => es.content_id, :my_field => '2', :locale => 'en')
    child = create_model(:locale => 'es', :test_model => es)
    assert_equal [child], en.test_models # precondition: shared translations works

    # test_models_test_models is the alias that Rails creates due to the join
    find_parent = ['test_models_test_models.test_model_id = ?', es.id]
    options = {:conditions => find_parent, :joins => :test_models}

    assert_equal [es], TestModel.my_field_is_1.locale('en', :all).all(options)
    assert_equal [], TestModel.my_field_is_1.locale('en').all(options)
    assert_equal [en], TestModel.my_field_is_2.locale('en').all(options)

    assert_equal [], TestModel.my_field_is_2.locale('ca').all(options)
    assert_equal [en], TestModel.my_field_is_2.locale('ca', 'en').all(options)
    assert_equal [en], TestModel.my_field_is_2.locale('ca', 'en', :all).all(options)

    complex_conditions = ['((test_models.my_field = ?) OR (test_models.my_field = ?))','0','2']
    assert_equal [en], TestModel.locale('es', :all).scoped(options).all(:conditions => complex_conditions)
  end

  def test_search_by_locale_with_virtual_shared_translations_edge_cases
    es = create_model(:my_field => '1', :locale => 'es')
    en = create_model(:content_id => es.content_id, :my_field => '2', :locale => 'en')
    child = create_model(:locale => 'es', :test_model => es)

    # test_models_test_models is the alias that Rails creates due to the join
    find_parent = ['test_models_test_models.test_model_id = ?', es.id]
    options = {:conditions => find_parent, :joins => :test_models}

    # Intercalate "mixed" and "strict" conditions.
    assert_equal [], TestModel.scoped(:conditions => ['(test_models.my_field = ?)', '1']).\
      scoped(options).my_field_is_2.locale('en', :all).all
  end

  def test_search_by_locale_without_virtual_shared_translations
    es = create_model(:my_field => '1', :locale => 'es')
    en = create_model(:content_id => es.content_id, :my_field => '2', :locale => 'en')
    child = create_model(:locale => 'es', :test_model => es)
    assert_equal [child], en.test_models # precondition: shared translations works

    # test_models_test_models is the alias that Rails creates due to the join
    find_parent = ['test_models_test_models.test_model_id = ?', es.id]
    options = {:conditions => find_parent, :joins => :test_models}

    assert_equal [es], TestModel.locale('en', :all, :mode => :strict).all(options)
    assert_equal [], TestModel.locale('en', :mode => :strict).all(options)
    assert_equal [es], TestModel.locale('es', :all, :mode => :strict).all(options)
    assert_equal [es], TestModel.locale('es', :mode => :strict).all(options)

    assert_equal [], TestModel.locale('ca', :mode => :strict).all(options)
    assert_equal [], TestModel.locale('ca', 'en', :mode => :strict).all(options)
    assert_equal [es], TestModel.locale('ca', 'en', :all, :mode => :strict).all(options)
    assert_equal [es], TestModel.locale('ca', 'es', :mode => :strict).all(options)
    assert_equal [es], TestModel.locale('ca', 'es', :all, :mode => :strict).all(options)
    assert_equal [es], TestModel.locale('ca', :all, :mode => :strict).all(options)
  end

  def test_search_by_locale_with_include
    model = create_model
    create_related_model(:test_model => model, :my_field => '1')
    create_related_model(:test_model => model, :my_field => '2')

    assert_equal [model], TestModel.all(:conditions => "related_test_models.my_field = '1'", :include => :related_test_models)
    assert_equal [], TestModel.locale('es', :all).all(:conditions => "related_test_models.my_field = '10'", :include => :related_test_models)
    assert_equal [model], TestModel.locale('es', :all).all(:conditions => "related_test_models.my_field = '1'", :include => :related_test_models)
  end

  def test_search_by_locale_with_joins
    model = create_model
    create_related_model(:test_model => model, :my_field => '1')
    create_related_model(:test_model => model, :my_field => '2')

    assert_equal [model], TestModel.all(:conditions => "related_test_models.my_field = '1'", :joins => :related_test_models)
    assert_equal [], TestModel.locale('es', :all).all(:conditions => "related_test_models.my_field = '10'", :joins => :related_test_models)
    assert_equal [model], TestModel.locale('es', :all).all(:conditions => "related_test_models.my_field = '1'", :joins => :related_test_models)
  end

  def test_search_by_locale_with_joins_in_another_named_scope
    model = create_model
    TestModel.class_eval do
      scope :scope_for_test, lambda{|id|
        {
          :joins => :related_test_models,
          :conditions => ["related_test_models.my_field = ?", id.to_s]
        }
      }
    end
    create_related_model(:test_model => model, :my_field => '1')
    create_related_model(:test_model => model, :my_field => '2')

    assert_equal [model], TestModel.scope_for_test(1).all
    assert_equal [], TestModel.locale('es', :all).scope_for_test(10).all
    assert_equal [], TestModel.scope_for_test(10).locale('es', :all).all
    assert_equal [model], TestModel.locale('es', :all).scope_for_test(1).all
  end

  def test_search_by_locale_with_custom_sql_joins
    model = create_model
    TestModel.class_eval do
      scope :scope_for_test, lambda{|id|
        {
          :joins => 'INNER JOIN related_test_models ON related_test_models.test_model_id = test_models.id',
          :conditions => ["related_test_models.my_field = ?", id.to_s]
        }
      }
    end
    create_related_model(:test_model => model, :my_field => '1')
    create_related_model(:test_model => model, :my_field => '2')

    assert_equal [model], TestModel.scope_for_test(1).all
    assert_equal [], TestModel.locale('es', :all).scope_for_test(10).all
    assert_equal [], TestModel.scope_for_test(10).locale('es', :all).all
    assert_equal [model], TestModel.locale('es', :all).scope_for_test(1).all
  end

  def test_search_by_locale_with_include_in_another_named_scope
    model = create_model
    TestModel.class_eval do
      scope :scope_for_test, lambda{|id|
        {
          :include => [:related_test_models],
          :conditions => ["related_test_models.my_field = ?", id.to_s]
        }
      }
    end
    create_related_model(:test_model => model, :my_field => '1')
    create_related_model(:test_model => model, :my_field => '2')

    assert_equal [model], TestModel.scope_for_test(1).all
    assert_equal [], TestModel.locale('es', :all).scope_for_test(10).all
    assert_equal [], TestModel.scope_for_test(10).locale('es', :all).all
    assert_equal [model], TestModel.locale('es', :all).scope_for_test(1).all
  end

  def test_search_by_locale_with_limit
    20.times do
      create_model(:locale => 'ca', :my_field => '1')
    end
    20.times do
      create_model(:locale => 'en', :my_field => '2')
    end

    assert_equal 40, TestModel.locale('es', :all).count
    assert_equal 10, TestModel.locale('es', :all).all(:conditions => "my_field = '1'", :limit => 10).size
    assert_equal 5, TestModel.locale('en', :all).all(:conditions => "my_field = '1'", :limit => 5).size
  end

  def test_search_by_locale_with_group_by
    10.times do
      create_model(:locale => 'ca', :my_field => '1')
    end
    20.times do
      create_model(:locale => 'en', :my_field => '2')
    end

    assert_equal_set [10, 20], TestModel.locale('es', :all).all(:select => 'COUNT(*) as numvalues', :group => :my_field).map(&:numvalues).map(&:to_i)
  end

  def test_search_by_locale_without_explicit_find
    model = create_model(:locale => 'ca', :my_field => '1')
    locale_evaled = TestModel.locale('es')
    no_evaled = TestModel.all
    assert_equal [], locale_evaled
    assert_equal [model], no_evaled
  end

  def test_search_by_locale_with_multiple_scope_avaluation
    # if something scoped is passed by reference to a function and is used there,
    # can be effectively avaluated more than once
    create_model(:locale => 'ca', :my_field => '1')
    locale_evaled = TestModel.locale('es')
    locale_evaled.size # first evaluation
    def second_eval to_eval
      assert_equal [], to_eval
    end
    second_eval locale_evaled
  end

  def test_search_by_locale_in_model_with_after_find
    CallbackTestModel.create(:my_field => "hola", :locale => "ca", :content_id => 2)
    CallbackTestModel.reset_counter
    CallbackTestModel.locale('ca', :all).first
    assert_equal 1, CallbackTestModel.after_find_counter
  end

  def test_search_by_locale_in_model_with_after_initialize
    CallbackTestModel.create(:my_field => "hola", :locale => "ca", :content_id => 2)
    CallbackTestModel.reset_counter
    CallbackTestModel.locale('ca', :all).first
    assert_equal 1, CallbackTestModel.after_initialize_counter
  end

  def test_search_by_locale_with_special_any_locale
    model = create_model(:locale => 'any', :my_field => '1')
    assert_equal [model], TestModel.locale('es')
    assert_equal 1, TestModel.locale('es').count
    assert_equal [model], TestModel.locale(:all)
    assert_equal 1, TestModel.locale(:all).count
  end

  def test_search_by_locale_should_work_with_symbols
    model = create_model(:locale => 'es', :my_field => '1')
    assert_equal [model], TestModel.locale(:es)
    assert_equal 1, TestModel.locale(:es).count
  end

  def test_search_by_locale_in_subclass
    ca = FirstSubclass.create(:locale => 'ca')
    es = ca.translate('es')
    es.save
    assert_equal [ca], FirstSubclass.locale('ca')
    assert_equal 1, FirstSubclass.locale('ca').count
    assert_equal [es], FirstSubclass.locale('es')
    assert_equal 1, FirstSubclass.locale(:all).count
  end

  def test_search_by_locale_in_subclass_doesnt_affect_superclass
    ca = FirstSubclass.create(:locale => 'ca')
    es = ca.translate('es')
    es.save
    FirstSubclass.locale('ca').size #.size to evaluate
    assert_equal_set [ca, es], InheritanceTestModel.all
  end

  def test_search_by_locale_in_different_deep_sti_class_levels
    ca = GrandsonClass.create(:locale => 'ca')
    es = ca.translate('es')
    es.save
    hierarchy = [GrandsonClass, FirstSubclass, InheritanceTestModel]
    (hierarchy + hierarchy.reverse).each do |klass|
      assert_equal [ca], klass.locale('ca')
      assert_equal 1, klass.locale('ca').count
      assert_equal [es], klass.locale('es')
      assert_equal 1, klass.locale(:all).count
    end
  end

  def test_search_by_locale_has_not_paginator_restrictions
    m1 = create_model(:locale => 'ca')
    m2 = create_model(:locale => 'ca')
    TestModel.send(:with_scope, :find => {:limit => 1}) do
      assert_equal_set [m2], TestModel.locale('ca').all(:order => 'id DESC')
    end
  end

  def test_search_translations
    es_m1 = create_model(:content_id => 1, :locale => 'es')
    ca_m1 = create_model(:content_id => 1, :locale => 'ca')
    de_m1 = create_model(:content_id => 1, :locale => 'de')
    es_m2 = create_model(:content_id => 2, :locale => 'es')
    en_m2 = create_model(:content_id => 2, :locale => 'en')
    en_m3 = create_model(:content_id => 3, :locale => 'en')

    assert_equal_set [es_m1, de_m1], ca_m1.translations
    assert_equal_set [ca_m1, de_m1], es_m1.translations
    assert_equal_set [en_m2], es_m2.translations
    assert_equal [], en_m3.translations
  end

  def test_translations_uses_class_method
    instance = create_model(:content_id => 1, :locale => 'es')
    TestModel.expects(:translations)
    instance.translations
  end

  def test_translations_finds_using_single_translatable_scope
    TestModel.class_eval do
      add_translatable_scope lambda{|el| "test_models.my_field = '#{el.my_field}'"}
    end

    es_1a = create_model(:content_id => 1, :locale => 'es', :my_field => 'a')
    en_1b = create_model(:content_id => 1, :locale => 'en', :my_field => 'b')
    es_2a = create_model(:content_id => 2, :locale => 'es', :my_field => 'a')
    en_2a = create_model(:content_id => 2, :locale => 'en', :my_field => 'a')

    assert_equal_set [], es_1a.translations
    assert_equal_set [], en_1b.translations
    assert_equal_set [en_2a], es_2a.translations
    # restore
    TestModel.instance_variable_set('@translatable_scopes', [])
  end

  def test_translations_finds_using_multiple_translatable_scopes
    TestModel.class_eval do
      add_translatable_scope lambda{|el| "test_models.my_field = '#{el.my_field}'"}
      add_translatable_scope lambda{|el| "test_models.my_other_field = '#{el.my_other_field}'"}
    end

    es_1a = create_model(:content_id => 1, :locale => 'es', :my_field => 'a', :my_other_field => 'a')
    en_1b = create_model(:content_id => 1, :locale => 'en', :my_field => 'b', :my_other_field => 'a')
    es_2a = create_model(:content_id => 2, :locale => 'es', :my_field => 'a', :my_other_field => 'a')
    en_2a = create_model(:content_id => 2, :locale => 'en', :my_field => 'a', :my_other_field => 'a')
    ca_2a = create_model(:content_id => 2, :locale => 'ca', :my_field => 'a', :my_other_field => 'b')

    assert_equal_set [], es_1a.translations
    assert_equal_set [], en_1b.translations
    assert_equal_set [en_2a], es_2a.translations
    assert_equal_set [], ca_2a.translations

    # restore
    TestModel.instance_variable_set('@translatable_scopes', [])
  end

  def test_translations_method_when_locale_is_nil
    es = create_model(:content_id => 1, :locale => 'es')
    en = es.translate('en')
    en.locale = nil
    assert_equal [es], en.translations
  end

  def test_should_not_update_translations_if_update_fails
    es_m1 = create_model(:content_id => 1, :locale => 'es', :my_other_field => 'val')
    ca_m1 = create_model(:content_id => 1, :locale => 'ca', :my_other_field => 'val')
    assert !es_m1.update_attributes(:my_other_field => 'newval', :abort_on_before_update => true)
    assert_equal 'val', es_m1.reload.my_other_field
    assert_equal 'val', ca_m1.reload.my_other_field
  end

  def test_should_not_update_translations_if_creation_fails
    es_m1 = create_model(:content_id => 1, :locale => 'es', :my_other_field => 'val')
    ca_m1 = TestModel.new(:content_id => 1, :locale => 'ca', :my_other_field => 'newval', :abort_on_before_create => true)
    assert !ca_m1.save
    assert_equal 'val', es_m1.reload.my_other_field
  end

  def test_update_in_another_locale_should_create_correct_instance
    Locale.current = 'es'
    instance = create_model
    assert_equal 'es', instance.locale
  end

  def test_update_in_another_locale_should_update_correct_instance
    ca = create_model(:locale => 'ca', :my_other_field => 'shared', :my_field => 'uniq_ca')
    Locale.current = 'es'
    assert_no_difference 'TestModel.count' do
      ca.update_attribute :my_field, 'new_uniq'
    end
    assert_equal 'new_uniq', ca.reload.my_field
    assert_equal 'shared', ca.my_other_field
  end

  def test_update_in_another_locale_should_update_correct_existing_instance
    ca = create_model(:locale => 'ca', :my_other_field => 'shared', :my_field => 'uniq_ca')
    es = ca.translate('es')
    es.save

    Locale.current = 'es'
    assert_no_difference 'TestModel.count' do
      ca.update_attribute :my_other_field, 'new_shared'
    end

    assert_equal 'es', es.locale
    assert_equal 'new_shared', ca.reload.my_other_field
    assert_equal 'new_shared', es.reload.my_other_field
  end

  def test_translate_should_create_translation_with_correct_values_when_copy_all_true_by_default
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = TestModel.translate(1, 'ca')
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal 'val', ca.my_field
    assert_equal 'val', ca.my_other_field
    assert ca.save
  end

  def test_translate_should_create_translation_with_correct_values_when_copy_all_true_by_default_in_instances
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = es.translate('ca')
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal 'val', ca.my_field
    assert_equal 'val', ca.my_other_field
    assert ca.save
  end

  def test_translate_should_not_create_translation_when_one_in_the_current_locale_exists
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = es.translate('ca')
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert ca.save

    ca_copy = es.translate('ca')
    assert_nil ca_copy.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale


    Locale.any_instance.expects(:native_name).returns('foo_test_value')

    assert !ca_copy.save
    assert_nil ca_copy.id

    assert ca_copy.errors[:locale].include?('foo_test_value')

    ca_copy = create_model(:content_id => 1, :locale => 'ca')
    assert_nil ca_copy.id
  end

  def test_translate_should_not_create_translation_when_one_in_the_current_locale_exists_automatically_assigning_locale
    locale = Locale.current
    begin
      Locale.current = 'es'
      es = create_model(:my_field => 'val', :my_other_field => 'val')
      ca = es.translate('ca')
      assert_nil ca.id
      assert_equal es.content_id, ca.content_id
      assert_equal 'ca', ca.locale
      assert ca.save

      # duplication, abort
      ca_copy = nil
      ca_copy = es.translate('ca')
      assert_nil ca_copy.id
      assert_equal es.content_id, ca.content_id
      assert_equal 'ca', ca.locale

      ca_copy.class.expects(:human_name).twice.returns('FooModelName')

      assert !ca_copy.save

      assert_equal 1, ca_copy.errors.size
      error_message = ca_copy.errors[:locale].to_s

      assert error_message.downcase.include?("catal&agrave;") || error_message.downcase.include?("català")
      assert error_message.include?("FooModelName")
      assert_nil ca_copy.id

      # duplication, abort
      # Here we use the same method applied in controllers: Model.create(:content_id => 1)
      Locale.current = 'ca'
      ca_copy = nil
      ca_copy = create_model(:content_id => es.content_id)
      assert_nil ca_copy.id
    ensure
      Locale.current = locale
    end
  end

  def test_translate_should_create_translation_with_correct_values_when_copy_all_false
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = TestModel.translate(1, 'ca', :copy_all => false)
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_nil ca.my_field
    assert_equal 'val', ca.my_other_field
    assert ca.save
  end

  def test_translate_should_create_new_instance_when_no_valid_content_id
    create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = TestModel.translate(2, 'ca')
    assert_equal nil, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal nil, ca.my_field
    assert_equal nil, ca.my_other_field
  end

  def test_translate_should_create_new_instance_when_no_content_id
    create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = TestModel.translate(nil, 'ca')
    assert_equal nil, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal nil, ca.my_field
    assert_equal nil, ca.my_other_field
  end

  def test_instance_translate_should_create_translation_with_correct_values
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = es.translate('ca', :copy_all => false)
    assert_nil ca.id
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_nil ca.my_field
    assert_equal 'val', ca.my_other_field
    assert ca.new_record?
  end

  def test_translate_with_copy_all_should_copy_common_attributes
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    ca = TestModel.translate(1, 'ca', :copy_all => true)
    assert_equal es.content_id, ca.content_id
    assert_equal 'ca', ca.locale
    assert_equal 'val', ca.my_field
    assert_equal 'val', ca.my_other_field
  end

  def test_in_locale_instance_method_with_one_locale
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    assert_equal es.id, en.in_locale('es').id
  end

  def test_in_locale_instance_method_with_two_locales
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    assert_equal es.id, en.in_locale('es', 'en').id
    assert_equal en.id, en.in_locale('en', 'es').id
    assert_equal en.id, en.in_locale('ca', 'en').id
  end

  def test_in_locale_instance_method_with_all_locales
    TestModel.delete_all
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    assert_equal es.id, en.in_locale('es', :all).id
    assert_equal en.id, en.in_locale('en', :all).id
    assert_equal es.id, en.in_locale('ca', 'es', :all).id
  end

  def test_destroy_contents
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    ca = create_model(:content_id => 1, :locale => 'ca', :my_field => 'val', :my_other_field => 'val')
    assert_equal 3, TestModel.count
    es.destroy
    assert_equal 2, TestModel.count
    ca.destroy_content
    assert_equal 0, TestModel.count
  end

  def test_destroy_contents_and_dependants
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    es.inheritance_test_models << InheritanceTestModel.create(:locale => 'es')
    es.inheritance_test_models << InheritanceTestModel.create(:locale => 'es')
    en = es.translate('en')
    en.save
    ca = es.translate('ca')
    ca.save
    assert_equal 3, TestModel.count
    assert_equal 2, InheritanceTestModel.count
    ca.destroy_content
    assert_equal 0, TestModel.count
    assert_equal 0, InheritanceTestModel.count
  end

  def test_destroy_contents_and_dependants_with_itself
    es = create_model(:locale => 'es', :my_field => 'val', :my_other_field => 'val')
    es.test_models << create_model(:locale => 'es')
    en = es.translate('en')
    en.save
    ca = es.translate('ca')
    ca.save
    assert_equal 4, TestModel.count
    ca.reload.destroy_content # reload to avoid #219
    assert_equal 0, TestModel.count # will fail if using destroy_all (same model)
  end

  def test_compare_locales
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    any = create_model(:content_id => 2, :locale => 'any', :my_field => 'val', :my_other_field => 'val')
    assert es.in_locale?('es')
    assert en.in_locale?('es', 'en')
    assert !en.in_locale?('ca', 'es')
    assert !es.in_locale?('ca')
    assert any.in_locale?('en')
    assert any.in_locale?('jp', 'fr', 'ca', 'es')
    assert any.in_locale?('any')
  end

  def test_compare_locales_without_any
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    any = create_model(:content_id => 2, :locale => 'any', :my_field => 'val', :my_other_field => 'val')
    assert es.in_locale?('es', :skip_any => true)
    assert en.in_locale?('es', 'en', :skip_any => true)
    assert !en.in_locale?('ca', 'es', :skip_any => true)
    assert !es.in_locale?('ca', :skip_any => true)
    assert !any.in_locale?('en', :skip_any => true)
    assert !any.in_locale?('jp', 'fr', 'ca', 'es', :skip_any => true)
    assert any.in_locale?('any', :skip_any => true)
  end

  def test_compare_locales_with_symbols
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    any = create_model(:content_id => 2, :locale => 'any', :my_field => 'val', :my_other_field => 'val')
    assert es.in_locale?(:es, :skip_any => true)
    assert en.in_locale?(:es, :en, :skip_any => true)
    assert !en.in_locale?(:ca, :es, :skip_any => true)
    assert !es.in_locale?(:ca, :skip_any => true)
    assert !any.in_locale?(:en, :skip_any => true)
    assert !any.in_locale?(:jp, :fr, :ca, :es, :skip_any => true)
    assert any.in_locale?(:any, :skip_any => true)
  end

  def test_compare_locales_with_locale_object
    es_locale = Locale.create(:iso_code => 'es')
    ca_locale = Locale.create(:iso_code => 'ca')
    es = create_model(:content_id => 1, :locale => 'es', :my_field => 'val', :my_other_field => 'val')
    en = create_model(:content_id => 1, :locale => 'en', :my_field => 'val', :my_other_field => 'val')
    assert es.in_locale?(es_locale)
    assert !en.in_locale?(es_locale)
    assert !es.in_locale?(ca_locale)
  end

  def test_named_scopes_work_on_subclasses_if_previously_loaded
    assert_nothing_raised do
      SecondSubclass.scopes.clear
      InheritanceTestModel.class_eval do
        translatable
      end
      SecondSubclass.locale('ca')
    end
  end

  def test_clone_ignoring_i18n_locales
    m = create_model
    assert !m.new_record?
    good_clone = m.clone
    bad_clone  = m.clone_without_i18n_fields_ignore
    assert_equal nil,          good_clone.content_id
    assert_equal m.content_id, bad_clone.content_id
  end

  def test_attributes_with_i18n_fields_assignement_advancement_assigning_fields_on_new
    attributes = {:content_id => 10, :locale => 'ca'}
    model = TestModel.new
    model.expects(:attributes_without_i18n_fields_assignement_advancement=).with do |param_attrs, guard|
      # the attributes where assigned in the overrided method, not in ActiveRecord's standard
      assert_equal 'ca', model.locale
      assert_equal 10, model.content_id
      param_attrs == attributes
    end
    model.attributes_with_i18n_fields_assignement_advancement = attributes
  end

  def test_attributes_with_i18n_fields_assignement_advancement_assigning_fields_in_assignement
    attributes = {:content_id => 10, :locale => 'ca'}

    # the method will do nothing
    TestModel.any_instance.expects(:attributes_without_i18n_fields_assignement_advancement=).with(attributes, true)
    model = TestModel.new(attributes)

    assert_equal 'ca', model.locale
    assert_equal 10, model.content_id
  end

  # ActiveRecord.localized method tests

  def test_localized_method_is_a_proxy_for_locale_with_current_locale_when_fallbacks_is_disabled
    Locale.use_fallbacks = false
    Locale.current = 'de'
    assert_equal [:de], TestModel.localized.where_values_hash[:locale_list].map(&:to_sym)
  end

  def test_localized_method_is_a_proxy_for_locale_with_current_locale_and_fallbacks_when_fallbacks_enabled
    Locale.use_fallbacks = true
    Locale.current = 'de'
    assert_equal [:de, :all], TestModel.localized.where_values_hash[:locale_list].map(&:to_sym)
    I18n.fallbacks.map(:de => :ca, :ca => :es)
    Locale.current = 'de-DE'
    assert_equal [:"de-DE", :de, :ca, :es, :all], TestModel.localized.where_values_hash[:locale_list].map(&:to_sym)
  end

end

create_test_model_backend
