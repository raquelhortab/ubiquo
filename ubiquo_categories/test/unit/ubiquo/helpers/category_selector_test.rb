require File.dirname(__FILE__) + "/../../../test_helper.rb"

#class Post < ActiveRecord::Base
#  attr_accessor :title
#  categorized_with :tags
#end

class Ubiquo::Helpers::CategorySelectorTest < ActionView::TestCase
  
  
  def setup
    category_set = CategorySet.create(:name => "Tags", :key => "tags")
    category_set.categories.build(:name => "Red")
    category_set.categories.build(:name => "Blue")
    category_set.save
  end
  
  def test_prints_selector_with_implicit_type
    form_for(:post, Post.new) do |f|
      concat f.category_selector(:tags, :type => 'checkbox')
      concat f.category_selector(:tags, :type => 'select')
    end
    
    expected = 
      "<form>" + category_checkbox_output + category_select_output + "</form>"
    
    assert_dom_equal expected, output_buffer
  end
  
  def test_category_select_selector
    require 'ruby-debug';debugger
    hola =  "hola"
  end
  
  private
  
  def category_checkbox_output
    "checkboxes"
  end
  
  def category_select_output
    "<select id=\"post_tags\" name=\"post[tags]\">" +
    "<option value=\"Blue\">Blue</option>" +
    "<option value=\"Red\">Red</option>" +      
    "</select"
  end
end
