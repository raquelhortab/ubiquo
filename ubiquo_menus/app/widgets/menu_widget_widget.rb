Widget.behaviour :menu_widget do |widget|
  @menu = widget.menu
  @block = widget.block

  @menu_name = @menu.name
#  @menu_name = widget.name if @block.block_type == "sidebar" &&
#                                widget.name != MenuWidget.default_name_for(widget)
  @menu_id = nil
  @menu_id = 'navigation' if @block.block_type == "top"

  @menu_class = nil
  @menu_class = 'box generic_list' if @block.block_type == "sidebar"

  @display_descriptions = nil
  @display_descriptions = widget.display_descriptions if @block.block_type == "sidebar" &&
                                                          widget.display_descriptions == "1"
end
