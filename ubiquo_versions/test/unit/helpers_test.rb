require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoVersions::Extensions::HelpersTest < ActionView::TestCase

  helper Ubiquo::Helpers::CoreUbiquoHelpers

  def setup
    set_test_model_as_versionable
  end

  def test_show_versions_for_an_existing_object_calls_the_partial
    model = TestVersionableModel.create
    self.expects(:render).once.with(
      :partial =>  "shared/ubiquo/model_versions",
      :locals => { :model => model }
    )
    show_versions(model)
  end

  def test_show_versions_contents
    model = TestVersionableModel.create
    model.update_column :my_field, 'new_value'
    show_versions(model)
#    html_content = HTML::Document.new(html)
#    assert_select "div.version-box" do
#      assert_select html_content.root, "div", 2
#    end
  end

  # Some stubs for helpers
  UbiquoVersions::Extensions::Helpers.module_eval do

    def url_for(options = {})
      options.to_s
    end

  end

  create_ar_test_backend_for_versionable
end
