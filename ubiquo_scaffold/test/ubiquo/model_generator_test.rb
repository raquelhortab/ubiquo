# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib/generators/ubiquo/model/model_generator')

class Ubiquo::ModelGeneratorTest < ::Rails::Generators::TestCase
  tests ::Ubiquo::ModelGenerator

  # -----------------------------
  # -*- model file generation -*-
  # -----------------------------
  test "should create model with title" do
    run_generator %w(Post title:string body:text)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_match /validates_presence_of :title/, content
      assert_match /filtered_search_scopes/, content
    end
  end

  test "should create model with name" do
    run_generator %w(Post name:string)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_match /validates_presence_of :name/, content
      assert_match /filtered_search_scopes/, content
    end
  end

  test "should create model without title or name" do
    run_generator %w(Post some_field:string)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_not_match /validates_presence_of :some_field/, content
      assert_match /filtered_search_scopes/, content
    end
  end

  test "should create model with one belongs_to relation" do
    run_generator %w(Post title:string --belongs-to author)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_match /belongs_to :author/, content
    end
  end

  test "should create model with multiple belongs_to relations" do
    run_generator %w(Post title:string --belongs-to author editor)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_match /belongs_to :author$/, content
      assert_match /belongs_to :editor$/, content
    end
  end

  test "should create model with one has_many relation" do
    run_generator %w(Post title:string --has-many authors)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_match /has_many :authors$/, content
    end
  end

  test "should create model with multiple has_many relations" do
    run_generator %w(Post title:string --has-many authors comments)

    assert_file 'app/models/post.rb' do |content|
      assert_match /class Post < ActiveRecord::Base/, content
      assert_match /has_many :authors$/, content
      assert_match /has_many :comments$/, content
    end
  end

  test "should create versionable model" do
    run_generator %w(Post title:string --versionable)

    assert_file 'app/models/post.rb' do |content|
      assert_match /versionable/, content
    end
  end

  test "should create versionable model with max versions amount" do
    run_generator %w(Post title:string --versionable --max-versions-amount 5)

    assert_file 'app/models/post.rb' do |content|
      assert_match /versionable max_amount: 5/, content
    end
  end

  test "should create translatable model" do
    run_generator %w(Post title:string body:text --translatable title body)

    assert_file 'app/models/post.rb' do |content|
      assert_match /translatable :title, :body/, content
    end
  end

  test "should create categorized model" do
    run_generator %w(Post title:string body:text --categorized colors tags)

    assert_file 'app/models/post.rb' do |content|
      assert_match /categorized_with :colors/, content
      assert_match /categorized_with :tags/, content
    end
  end

  test "should create model with media" do
    run_generator %w(Post title:string body:text --media images videos)

    assert_file 'app/models/post.rb' do |content|
      assert_match /media_attachment :images, types: %w\(image doc video audio flash\)/, content
      assert_match /media_attachment :videos, types: %w\(image doc video audio flash\)/, content
    end
  end

  # ---------------------------------
  # -*- migration file generation -*-
  # ---------------------------------
  test "should create migration" do
    run_generator %w(Post title:string body:text)

    assert_migration 'db/migrate/create_posts.rb' do |content|
      assert_match /class CreatePosts < ActiveRecord::Migration/, content

      assert_class_method :up, content do |up|
        assert_match /create_table :posts/, up
        assert_match /t\.string :title/, up
        assert_match /t\.text :body/, up
        assert_match /t\.timestamps/, up
      end

      assert_class_method :down, content do |down|
        assert_match /drop_table :posts/, down
      end
    end
  end

  test "should create migration with belongs_to relations" do
    run_generator %w(Post title:string --belongs-to author editor)

    assert_migration 'db/migrate/create_posts.rb' do |content|
      assert_match /class CreatePosts < ActiveRecord::Migration/, content

      assert_class_method :up, content do |up|
        assert_match /create_table :posts/, up
        assert_match /t\.integer :author_id/, up
        assert_match /t\.integer :editor_id/, up
      end
    end
  end

  test "should create migration with has_many relations" do
    run_generator %w(Post title:string --has-many authors comments)

    assert_migration 'db/migrate/create_posts.rb' do |content|
      assert_match /class CreatePosts < ActiveRecord::Migration/, content

      assert_class_method :up, content do |up|
        assert_match /create_table :posts/, up
        %w(Author Comment).each do |klass|
          assert_match /if defined\?\(#{klass}\) && #{klass}.table_exists\?/, up
          assert_match /#{klass}\.reset_column_information/, up
          assert_match /unless #{klass}\.column_names\.include\?\('post_id'\)/, up
          assert_match /add_column #{klass}\.table_name, :post_id, :integer/, up
        end
      end
    end
  end

  test "should skip migration" do
    run_generator %w(Post title:string --skip-migration)

    assert_no_migration 'db/migrate/create_posts.rb'
  end

  test "should create migration with versionable and translatable options" do
    run_generator %w(Post title:string --translatable title --versionable)

    assert_migration 'db/migrate/create_posts.rb' do |content|
      assert_match /class CreatePosts < ActiveRecord::Migration/, content

      assert_class_method :up, content do |up|
        assert_match /create_table :posts, versionable: true, translatable: true/, up
      end
    end
  end

  test "should create migration with categories" do
    run_generator %w(Post title:string --categorized colors)

    assert_migration 'db/migrate/create_posts.rb' do |content|
      assert_match /class CreatePosts < ActiveRecord::Migration/, content

      assert_class_method :up, content do |up|
        assert_match /unless ::CategorySet\.find_by_key\('colors'\)/, up
        assert_match /::CategorySet\.create\(key: 'colors', name: 'Colors'\)/, up
      end
    end
  end

  # ---------------------------------
  # -*- unit test file generation -*-
  # ---------------------------------
  test "should create unit test with title" do
    run_generator %w(Post title:string body:text)

    assert_file 'test/unit/post_test.rb' do |content|
      assert_match /class PostTest < ActiveSupport::TestCase/, content
      assert_match /test "should create post"/, content
      assert_match /test "should require title"/, content
      assert_match /test "should filter by title"/, content
      assert_instance_method :create_post, content
    end
  end

  test "should create unit test with name" do
    run_generator %w(Post name:string body:text)

    assert_file 'test/unit/post_test.rb' do |content|
      assert_match /class PostTest < ActiveSupport::TestCase/, content
      assert_match /test "should create post"/, content
      assert_match /test "should require name"/, content
      assert_match /test "should filter by name"/, content
      assert_instance_method :create_post, content
    end
  end

  test "should create unit test without title or name" do
    run_generator %w(Post other:string)

    assert_file 'test/unit/post_test.rb' do |content|
      assert_match /class PostTest < ActiveSupport::TestCase/, content
      assert_match /test "should create post"/, content
      assert_not_match /test "should require/, content
      assert_not_match /test "should filter by/, content
      assert_instance_method :create_post, content
    end
  end

  test "should create unit test with published_at" do
    run_generator %w(Post published_at:date)

    assert_file 'test/unit/post_test.rb' do |content|
      assert_match /class PostTest < ActiveSupport::TestCase/, content
      assert_match /test "should filter by publish date"/, content
    end
  end

  test "should create fixtures" do
    run_generator %w(Post title:string body:text)

    assert_file 'test/fixtures/posts.yml' do |content|
      %w(one two).each do |name|
        assert_match /#{name}:/, content
        assert_match /title: 'MyString'/, content
        assert_match /body: 'MyText'/, content
      end
    end
  end

  test "should skip fixtures" do
    run_generator %w(Post title:string --skip-fixtures)

    assert_no_file 'test/fixtures/posts.yml'
  end

  test "should create empty fixtures without attributes" do
    run_generator %w(Post)

    assert_file 'test/fixtures/posts.yml' do |content|
      %w(one two).each do |name|
        assert_match /# #{name}:/, content
        assert_match /column: 'value'/, content
      end
    end
  end

  test "should create fixtures with versionable option" do
    run_generator %w(Post title:string body:text --versionable)

    assert_file 'test/fixtures/posts.yml' do |content|
      %w(one two).each_with_index do |name, i|
        assert_match /#{name}:/, content
        assert_match /content_id: 1/, content
        assert_match /version_number: #{i + 1}/, content
        assert_match /is_current_version: #{(i + 1) == 1 ? 'true' : 'false'}/, content
        assert_match /parent_version: 'one'/, content
      end
    end
  end

  test "should create fixtures with translatable option" do
    run_generator %w(Post title:string body:text --translatable title)

    assert_file 'test/fixtures/posts.yml' do |content|
      %w(one two).each_with_index do |name, i|
        assert_match /#{name}:/, content
        assert_match /content_id: 1/, content
        assert_match /locale: 'en'/, content
      end
    end
  end

  # -----------------------------
  # -*- i18n files generation -*-
  # -----------------------------
  test "should create traslation files" do
    run_generator %w(Post body:text --has-many comments --belongs-to author)

    %w(ca es en).each do |locale|
      assert_file "config/locales/#{locale}/models/post.yml" do |content|
        assert_match /^#{locale}:/, content
        assert_match /post: "Post"/, content
        assert_match /body: "Body"/, content
        assert_match /author: "Author"/, content
        assert_match /comments: "Comments"/, content
      end
    end
  end

  test "should set correct translations in the translatable fields" do
    run_generator %w(Post title:string name:string published_at:date)

    assert_file "config/locales/ca/models/post.yml" do |content|
      assert_match /^ca:/, content
      assert_match /title: "Títol"/, content
      assert_match /name: "Nom"/, content
      assert_match /published_at: "Data de publicació"/, content
    end

    assert_file "config/locales/es/models/post.yml" do |content|
      assert_match /^es:/, content
      assert_match /title: "Título"/, content
      assert_match /name: "Nombre"/, content
      assert_match /published_at: "Fecha de publicación"/, content
    end

    assert_file "config/locales/en/models/post.yml" do |content|
      assert_match /^en:/, content
      assert_match /title: "Title"/, content
      assert_match /name: "Name"/, content
      assert_match /published_at: "Published at"/, content
    end
  end
end
