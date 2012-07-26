# -*- encoding: utf-8 -*-

class AssetPublic < Asset
  file_attachment :resource,
                  :visibility => 'public',
                  :styles     => self.correct_styles(Ubiquo::Settings.context(:ubiquo_media).get(:media_styles_list)),
                  :processors => Ubiquo::Settings.context(:ubiquo_media).get(:media_processors_list),
                  :storage    => Ubiquo::Settings.context(:ubiquo_media).get(:media_storage)

  validates :resource, :attachment_presence => true

  after_resource_post_process :generate_geometries
end
