#= Ubiquo scaffolding 
# 
#== Generation 
#
#Similarly to the Rails scaffold, _ubiquo_scaffold_ creates code to handle resources on an application. It creates a model (with tests), migration, route, ubiquo controller (with tests) and ubiquo views. As an example, let's create a scaffold for a _Book_ model:
#   
#  script/generate ubiquo_scaffold book title:string published_at:datetime author_id:integer
#  rake db:migrate
# 
#REST resources for this model will be created automatically. Check it out:
#
#  map.namespace :ubiquo do |ubiquo|
#     ubiquo.resources :books
#     ...
#  end
#
#== Navigation tabs 
#
#Add a tab for the new resource on the main navigation tab:
#
#  #app/views/navigators/_main_navtabs.html.erb
#   <% navigator_left = create_tab_navigator(:tab_options => {}) do |navigator|
#      ...
#      navigator.add_tab do |tab|
#        tab.text = t("Books")
#        tab.title = t("Go to books management")
#        tab.link = ubiquo_books_path
#        tab.highlights_on({:controller => "ubiquo/books"})
#        tab.highlighted_class = "active"
#      end if permit?("books_management")
#      ...
#    end
#    %>
#    <%= render_tab_navigator(navigator_left) %>
# 
# 
#Note that the permission is not automatically created.
# 
#- Edit <tt>app/views/ubiquo/books/_submenu.html.erb</tt> and set the used naviation for this ubiquo section (normally, using the controller name):
# 
#  <%= navigation :books %>
# 
#  At this moment the navigation is read from <tt>app/views/navigators/_books_navlinks.html.erb</tt>. Create the file and edit accordingly:
#
#  <%
#      navigator_books = create_link_navigator(:id =>"general_configuration", :link_options => {}) do |navigator|
#         ...
#         navigator.add_link do |link|
#          link.text = t("Books")
#          link.url = ubiquo_books_path
#          link.highlights_on({:controller => "ubiquo/books"})
#          end
#          ...
#      end
#  %>
#  <%= render_link_navigator(navigator_books) %>
# 
#Imagine now that you want to add an _authors_ resource. If you need it to appear on the same tab that _books_, edit the books navigation file and add a _authors_ link:
# 
#  <%
#      navigator_books = create_link_navigator(:id =>"general_configuration", :link_options => {}) do |navigator|
#         
#         navigator.add_link do |link|
#           link.text = t("Books")
#           link.url = ubiquo_books_path
#           link.highlights_on({:controller => "ubiquo/books"})
#         end
#         
#         navigator.add_link do |link|
#           link.text = t("Authors")
#           link.url = ubiquo_authors_path
#           link.highlights_on({:controller => "ubiquo/authors"})
#         end
#         
#      end
#  %>
#  <%= render_link_navigator(navigator_books) %>
# 
# 
#You also have to indicate on the main tab navigation to select the _Users_ tab when the item _authors_ is selected:
# 
# 
#   #app/views/navigators/_main_navtabs.html.erb
#   <% navigator_left = create_tab_navigator(:tab_options => {}) do |navigator|
#      ...
#        navigator.add_tab do |tab|
#          tab.text = t("Books")
#          tab.title = t("Go to books management")
#         tab.link = ubiquo_books_path
#         tab.highlights_on({:controller => "ubiquo/books"})
#         tab.highlights_on({:controller => "ubiquo/authors"})
#         tab.highlighted_class = "active"
#        end if permit?("books_management")
#      ...
#    end
#    %>
#    <%= render_tab_navigator(navigator_left) %>
# 
# 
#== Index listing 
# 
#Listing items in Ubiquo are commonly used on _index_ actions. The _ubiquo_scaffolding_ created views for the common operations, _index_ amongst them. 
# 
#The index template use the partial (<tt>app/views/shared/ubiquo/_list.html.erb</tt>) to render the table with the items. Let's see its parameters:
#
#Required locals:
#
#- name: The name of the model listed.
#- headers: Hash. The key is the field name of the model listed (used to sort). The value is the string to show.
#- rows: An Array with each row of the list. Each row is a Hash:
#  - id:  The id of this element
#  - columns: An Array with the columns values of this element
#  - actions: An Array with the actions for this element
#-  pages: Pagination for this list.
#
#Optional locals:
#
#* actions_width: Width (in pixels) of the Actions column (default is 100)
#* hide_actions: Set to true to hide actions (default is false)
#
# And an example that prints the book index:
#
#  <%= render(:partial => "shared/ubiquo/list", :locals => {
#    :name => 'book',
#    :headers => [:title, :author_id, :published_at],
#    :rows => @books.collect do |book|
#      {
#        :id => book.id,
#        :columns => [
#          book.title,
#          book.author.name,
#          book.published_at.to_s(:french),
#        ],
#        :actions => [
#          link_to(t('Edit'), edit_ubiquo_book_path(book)),
#          link_to(t('Remove'), [:ubiquo, book], :confirm => t('Are you sure you want to remove this book?'), 
#                                                 :method => :delete)
#        ]
#      }
#    end,
#    :pages => @books_pages
#  }) %>
#
#= Applying filters to model and controllers 
#
#You have to adapt the model and controller to work with filters. Get the query string from ''params'', process them (if necessary) and pass to the model, which should use them to build SQL conditions. Let's see an example, a text filter for our book model (searches case-insensitive on name and description).
#
#== Controller 
#
#  # test/functional/ubiquo/books_controller_test.rb
#  class Ubiquo::BooksControllerTest < ActionController::TestCase
#    ...
#    def test_filter_by_text_searching_case_insensitive_on_name_and_description
#      Book.delete_all
#      book1 = create_book(:name => 'name1', :description => 'description1')
#      book2 = create_book(:name => 'name2', :description => 'description2')
#      get :index, :filter_text => 'name'
#      assert_equal_set [book1, book2], assigns(:books)
#      get :index, :filter_text => 'NAME1'
#      assert_equal_set [book1], assigns(:books)
#      get :index, :filter_text => 'description2'
#      assert_equal_set [book2], assigns(:books)
#    end
#    ...
#  end
#
#  # app/controllers/ubiquo/books_controller.rb
#
#  class Ubiquo::BooksController < UbiquoAreaController
#    ...
#    # GET /books
#    # GET /books.xml
#    def index
#      respond_to do |format|
#        format.html {
#          params[:order_by] = params[:order_by] || 'books.id'
#          params[:sort_order] = params[:sort_order] || 'desc'
#          filters = {
#            :text => params[:filter_text],
#          }
#          @books_pages, @books = Book.paginate(:page => params[:page]) do
#            Book.filtered_search(filters, :order => params[:order_by] + " " + params[:sort_order])
#          end
#        } # index.html.erb
#        format.xml  {
#          @books = Book.find(:all)
#          render :xml => @books
#        }
#      end
#    end
#    ...
#  end
#
#== Model ==
#
#  # test/unit/book_test.rb
#  class BookTest < ActiveSupport::TestCase
#    def test_filter_by_text_searching_case_insensitive_on_name_and_description
#      Book.delete_all
#      book1 = create_book(:name => 'name1', :description => 'description1')
#      book2 = create_book(:name => 'name2', :description => 'description2')
#      assert_equal_set [book1, book2], Book.filtered_search({:text => 'name'})
#      assert_equal_set [book1], Book.filtered_search({:text => 'nAMe1'})
#      assert_equal_set [book2], Book.filtered_search({:text => 'DESCRIPTION2'})    
#    end
#  end
#  
#  # app/models/book.rb
#  class Book < ActiveRecord::Base
#    ...
#    def self.filtered_search(filters = {}, options = {})
#      filter_text = unless filters[:text].blank?
#        args = ["%#{filters[:text]}%"] * 2
#        condition = "upper(books.name) ILIKE upper(?) OR upper(books.description) ILIKE upper(?)"
#        {:find => {:conditions => [condition] + args}}
#      else
#        {}
#      end
#      with_scope(filter_text) do
#        with_scope(:find => options) do
#          Book.find(:all)
#        end
#      end
#    end
#  end  

class UbiquoScaffoldGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :has_published_at
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end

  def manifest
    record do |m|
      @has_published_at = !attributes.map(&:name).find{|a|a.to_s == "published_at"}.nil?
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, and test directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers/ubiquo', controller_class_path))
      m.directory(File.join('app/helpers/ubiquo', controller_class_path))
      m.directory(File.join('app/views/ubiquo', controller_class_path, controller_file_name))
      m.directory(File.join('test/functional/ubiquo', controller_class_path))
      m.directory(File.join('test/unit', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views/ubiquo', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end
      
      for partial in scaffold_partials
        m.template(
          "_view_#{partial}.html.erb",
          File.join('app/views/ubiquo', controller_class_path, controller_file_name, "_#{partial}.html.erb")
        )
      end
      m.template(
        "_view_model_show.html.erb",
        File.join('app/views/ubiquo', controller_class_path, controller_file_name, "_#{singular_name}.html.erb")
        )
      
      for locale in Ubiquo::Config.get(:supported_locales)
        m.template(
          "#{locale}.yml",
          File.join('config/locales', locale, 'ubiquo', "#{singular_name}.yml")
         )
      end
      
      m.template(
        "_navlinks.html.erb",
        File.join('app/views/navigators', "_#{controller_file_name}_navlinks.html.erb")
      )

      m.dependency 'ubiquo_model', [name] + @args, :collision => :skip

      m.template(
        'controller.rb', File.join('app/controllers/ubiquo', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional/ubiquo', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb', File.join('app/helpers/ubiquo', controller_class_path, "#{controller_file_name}_helper.rb"))

      m.namespaced_route_resources "ubiquo", controller_file_name
      puts "Notes:
      
  - Add new permissions to fixture db/dev_bootstrap/permissions.yml if needed. 
  - Add tabs on app/views/navigators/_main_navtabs.html.erb
  - Create app/views/navigators/_#{controller_file_name}_navtabs.html.erb tab file if needed.
      "
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--versionable",
             "Creates a versionable model") { |v| options[:versionable] = v}
      opt.on("--max-versions-amount [N]", Integer,
             "Set max versions amount for versionable models") { |v| options[:versions_amount] = v}
      opt.on("--translatable f1,f2...", Array,
        "Creates a translatable model") { |v| options[:translatable] = v}
    end

    def scaffold_views
      %w[ index new edit show ]
    end
    def scaffold_partials
      %w[ form submenu title ]
    end

    def model_name
      class_name.demodulize
    end
end
