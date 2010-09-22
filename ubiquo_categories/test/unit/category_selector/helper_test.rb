require File.dirname(__FILE__) + "/../../test_helper.rb"

class UbiquoCategories::CategorySelector::HelperTest < ActionView::TestCase
    
  def setup
    @set = CategorySet.create(:name => "Tags", :key => "tags")
    @set.categories.build(:name => "Red")
    @set.categories.build(:name => "Blue")
    @set.save
  end

  def test_category_selector_in_form_object
    categorize :tags
    object = CategoryTestModel.new
    self.expects(:category_selector).with(:post, :tags, {:object => object}, {})
    form_for(:post, object, :url => '') do |f|
      f.category_selector :tags
    end
  end

  def test_prints_selector_with_explicit_type
    categorize :tags
    form_for(:post, CategoryTestModel.new, :url => '') do |f|
      concat f.category_selector(:tags, :type => 'checkbox')
      concat f.category_selector(:tags, :type => 'select')
    end

    doc = HTML::Document.new(output_buffer)
    assert_select doc.root, 'form' do
      assert_select 'input[type=checkbox]'
      assert_select 'select'
    end
  end

  def test_from_options_available
    categorize :tags
    create_set :cities
    categorize(:using_from, :from => :cities)

    assert_nothing_raised do
      form_for(:post, CategoryTestModel.new, :url => '') do |f|
        concat f.category_selector(:using_from)
      end
    end
    
  end

  
  def test_category_selector_should_be_autocomplete_when_many_categories
    categorize :tags
    current_categories_amount = @set.categories.size
    max = Ubiquo::Config.context(:ubiquo_categories).get(:max_categories_simple_selector)
    
    (max + 1 - current_categories_amount).times do
      @set.categories << rand.to_s
    end
    assert_equal max + 1, @set.categories.size
    
    self.expects('category_autocomplete_selector').returns('')
    category_selector 'name', :tags, :object => CategoryTestModel.new
  end

  def test_category_selector_should_be_select_when_one_possible_category
    categorize :tags
    categorize :city, :size => 1
    create_set :cities

    self.expects('category_select_selector').returns('')
    category_selector 'name', :city, :object => CategoryTestModel.new
  end

  def test_category_selector_should_be_checkbox_when_one_possible_category
    categorize :tags
    categorize :city, :size => :many
    create_set :cities

    self.expects('category_checkbox_selector').returns('')
    category_selector 'name', :city, :object => CategoryTestModel.new
  end

  def test_category_selector_have_fieldset_and_legend
    categorize :tags
    output = category_selector 'name', :tags, :object => CategoryTestModel.new
    doc = HTML::Document.new(output)
    assert_select doc.root, 'fieldset' do
      assert_select 'legend'
    end
  end

  def test_category_selector_should_show_new_buttons_if_is_editable
    categorize :tags
    object = CategoryTestModel.new
    output = category_selector 'name', :tags, { :object => object }, { :id => 'html_id' }
    doc = HTML::Document.new(output)
    assert_select doc.root, 'fieldset[id=html_id]'
    assert_select doc.root, '.new_category_controls' do
      assert_select doc.root, '.category_selector_new'
      assert_select doc.root, '.add_new_category' do
        assert_select doc.root, '.add_new_category_link'
      end
    end
  end

  def test_category_selector_shouldnt_show_new_category_buttons
    categorize :tags
    @set.update_attributes(:is_editable => false)
    object = CategoryTestModel.new
    output = category_selector 'name', :tags, { :object => object }, { :id => 'html_id' }
    doc = HTML::Document.new(output)
    # first, check if category selector is printed
    assert_select doc.root, 'fieldset[id=html_id]'
    # now, check that all new categories controls aren't displayed
    assert_select doc.root, '.new_category_controls', 0
    assert_select doc.root, '.category_selector_new', 0
    assert_select doc.root, '.add_new_category', 0
  end

  def test_fieldset_has_html_options
    categorize :tags
    object = CategoryTestModel.new
    output = category_selector 'name', :tags, {:object => object}, {:id => 'html_id'}
    doc = HTML::Document.new(output)
    assert_select doc.root, 'fieldset[id=html_id]'
  end

  def test_legend_uses_name_if_present
    categorize :tags
    object = CategoryTestModel.new
    output = category_selector 'name', :tags, {:object => object, :name => 'legend'}
    doc = HTML::Document.new(output)
    assert_select doc.root, 'legend', 'legend'
  end

  def test_legend_uses_relation_name_if_no_name
    categorize :tags
    output = category_selector 'name', :tags, {:object => CategoryTestModel.new}
    doc = HTML::Document.new(output)
    assert_select doc.root, 'legend', CategoryTestModel.human_attribute_name(:tags)
  end

  def test_category_select_selector
    categorize :tags
    object = CategoryTestModel.new
    assert_nothing_raised do
      category_select_selector object, 'name', :tags, @set.categories, @set
    end
  end

  def test_should_raise_categorization_not_found_when_baseclass_have_not_been_categorized
    object = EmptyTestModelSubOne.new
    assert_raise UbiquoCategories::CategorizationNotFoundError do
      category_selector 'name', :tags, {:object => object}, {:id => 'html_id'}
    end
    object = EmptyTestModelSubTwo.new
    assert_raise UbiquoCategories::CategorizationNotFoundError do
      category_selector 'name', :tags, {:object => object}, {:id => 'html_id'}
    end
  end
  
  def test_should_not_raise_categorization_not_found_when_baseclass_have_been_categorized
    categorize_base :tags
    object = CategoryTestModelSubOne.new    
    assert_nothing_raised do
      category_selector 'name', :tags, {:object => object}, {:id => 'html_id'}
    end
    object = CategoryTestModelSubTwo.new
    assert_nothing_raised do
      category_selector 'name', :tags, {:object => object}, {:id => 'html_id'}
    end
  end

end

create_categories_test_model_backend
