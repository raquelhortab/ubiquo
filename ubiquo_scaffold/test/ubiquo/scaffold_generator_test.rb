# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib/generators/ubiquo/scaffold/scaffold_generator')

class Ubiquo::ScaffoldGeneratorTest < ::Rails::Generators::TestCase
  tests ::Ubiquo::ScaffoldGenerator

  test "should call model and controller generators" do
    run_generator %w(Post title:string)

    # model generator
    assert_file 'app/models/post.rb'
    assert_migration 'db/migrate/create_posts.rb'
    assert_file 'test/unit/post_test.rb'
    assert_file 'test/fixtures/posts.yml'

    # controller generator
    assert_file 'app/controllers/ubiquo/posts_controller.rb'
    assert_file 'app/views/ubiquo/posts/index.html.erb'
    assert_file 'app/views/ubiquo/posts/edit.html.erb'
    assert_file 'app/views/ubiquo/posts/new.html.erb'
    assert_file 'app/views/ubiquo/posts/show.html.erb'
    assert_file 'app/views/ubiquo/posts/_post.html.erb'
    assert_file 'app/views/ubiquo/posts/_form.html.erb'
    assert_file 'app/views/ubiquo/posts/_submenu.html.erb'
    assert_file 'app/views/ubiquo/posts/_title.html.erb'
    assert_file 'app/views/navigators/_posts_navlinks.html.erb'
    assert_file 'app/helpers/ubiquo/posts_helper.rb'
    assert_file 'test/functional/ubiquo/posts_controller_test.rb'

    # i18n files
    %w(ca es en).each do |locale|
      assert_file "config/locales/#{locale}/models/post.yml"
      assert_file "config/locales/#{locale}/ubiquo/post.yml"
    end
  end

  test "should run migration" do
    Kernel.expects(:system).with('rake db:migrate').returns(true)
    run_generator %w(Post title:string --run-migration)

    assert_migration 'db/migrate/create_posts.rb'
  end
end
