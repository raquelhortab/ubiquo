class MenuWidget < Widget
  self.allowed_options = [:menu_id, :display_descriptions]

  validates_presence_of :menu_id

  def menu
    Menu.find menu_id if self.menu_id.present?
  end
end
