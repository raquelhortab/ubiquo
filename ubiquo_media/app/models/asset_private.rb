class AssetPrivate < Asset
  file_attachment :resource, :visibility => "protected",
                  :styles => Ubiquo::Config.context(:ubiquo_media).get(:media_styles_list),
                  :processors => Ubiquo::Config.context(:ubiquo_media).get(:media_processors_list)  
  validates_attachment_presence :resource
end
