require File.dirname(__FILE__) + '/../helper.rb'

class TestGenerator < Test::Unit::TestCase

  def test_should_create_a_new_generator
    template = 'mygenerator.rb'
    assert Generator.new(template, Options.new(['myapp']) )
  end
end
