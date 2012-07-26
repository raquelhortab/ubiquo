class MenuWidget < Widget
  self.allowed_options = [:menu_id, :display_descriptions]

  validates :menu_id, :presence => true

  def menu
    Menu.find menu_id if self.menu_id.present?
  end
end
