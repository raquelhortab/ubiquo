class Post < ActiveRecord::Base
  has_paper_trail

  filtered_search_scopes

end
