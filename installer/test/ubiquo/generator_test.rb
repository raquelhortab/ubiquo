require File.dirname(__FILE__) + '/../helper.rb'

class TestGenerator < Test::Unit::TestCase

  def test_should_be_able_to_build_a_template
    skeleton = File.join(File.dirname(__FILE__), "../fixtures", "template.erb")
    opts = Options.new(%w[ --edge --sqlite --minimal myapp ])
    rails_template = Generator.build_template(opts, skeleton)
    assert_kind_of String, rails_template
    assert_match 'myapp', rails_template
    assert_match 'choosen_adapter = "sqlite"', rails_template
    assert_match 'choosen_plugin_set = "minimal"', rails_template
    assert_match 'ubiquo_branch = nil', rails_template
  end
  
end
