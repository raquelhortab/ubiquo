require File.dirname(__FILE__) + '/../helper.rb'

class TestGenerator < Test::Unit::TestCase

  def setup
    @tpl_skeleton = File.join(File.dirname(__FILE__), "../fixtures", "template.erb")
    @opts = Options.new(['myapp'])
  end
  
  def test_should_create_a_new_generator
    assert Generator.new(@opts, @tpl_skeleton)
  end

  def test_should_be_able_to_build_a_template
    opts = Options.new(%w[ --edge --sqlite --minimal myapp ])
    generator = Generator.new(opts, @tpl_skeleton)
    rails_template = generator.build_rails_template
    assert_kind_of String, rails_template
    assert_match 'myapp', rails_template
    assert_match 'choosen_adapter = "sqlite"', rails_template
    assert_match 'choosen_plugin_set = "minimal"', rails_template
#    assert_match 'ubiquo_branch = nil', rails_template
    require 'pp'; puts rails_template; exit
  end
end
