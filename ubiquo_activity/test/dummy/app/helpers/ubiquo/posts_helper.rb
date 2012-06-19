module Ubiquo::PostsHelper
  def post_filters
    filters_for "Post" do |f|
      f.text
    end
  end

  def post_list(collection, pages, options = {})
    render(partial: 'shared/ubiquo/lists/standard',
           locals: {
             name:    'post',
             headers: [:title],
             rows:    collection.map { |post|
               {
                 id: post.id,
                 columns: [
                   post.title
                 ],
                 actions: post_actions(post)
               }
             },
             pages:       pages,
             link_to_new: link_to(t("ubiquo.post.index.new"),
                                  ubiquo.new_post_path, class: 'new')
           }
    )
  end

  private

  def post_actions(post, options = {})
    actions = []
    actions << link_to(t("ubiquo.edit"),
                       [ubiquo, :edit, post],
                       class: 'btn-edit')
    actions << link_to(t("ubiquo.remove"),
               [ubiquo, post],
               confirm: t("ubiquo.post.index.confirm_removal"),
               method:  :delete,
               class:   'btn-delete')

    actions
  end
end
