class StaticSection < Widget
  self.allowed_options = [:title, :summary, :body]
  validates :title, :presence => true
  media_attachment :image, :size => 1, :types => ["image"]
  media_attachment :docs, :size => :many
end
