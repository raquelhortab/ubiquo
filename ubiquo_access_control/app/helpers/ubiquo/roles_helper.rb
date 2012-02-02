module Ubiquo::RolesHelper
  def role_filters
  end

  def role_list(collection, pages, options = {})
    render(:partial => "shared/ubiquo/lists/standard", :locals => {
      :name => 'role',
      :headers => [:name],
      :rows => collection.collect do |role|
        {
          :id => role.id,
          :columns => [role.name],
          :actions => role_index_actions(role)
        }
      end,
      :pages => pages,
      :link_to_new => link_to(t('ubiquo.auth.role_new'), ubiquo.new_role_path, :class => "new")
    })
  end

  def role_index_actions(role)
    [
      link_to(t('ubiquo.edit'), ubiquo.edit_role_path(role), :class => 'btn-edit'),
      link_to(t('ubiquo.remove'), ubiquo.role_path(role),
        :confirm => t('ubiquo.auth.confirm_role_removal'),
        :method => :delete, :class => 'btn-delete')
    ]
  end

end
