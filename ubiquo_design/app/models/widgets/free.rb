class Free < Widget
  self.allowed_options = [:content]

  validates :content, :presence => true

end
