module UbiquoMedia
  module Extensions
    autoload :Helper, 'ubiquo_media/extensions/helper'
  end
end

:UbiquoController.helper! UbiquoMedia::Extensions::Helper


