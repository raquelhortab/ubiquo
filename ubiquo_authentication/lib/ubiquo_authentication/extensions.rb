module UbiquoAuthentication
  module Extensions
  end
end

Ubiquo::Extensions::Loader.append_helper(:UbiquoController, UbiquoAuthentication::Extensions::Helper)
Ubiquo::Extensions::Loader.append_include(:UbiquoController, UbiquoAuthentication::Extensions::Controller)
