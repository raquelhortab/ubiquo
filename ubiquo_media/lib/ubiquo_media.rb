# -*- encoding: utf-8 -*-

module UbiquoMedia
  def self.valid_rails?
    defined?(Rails) && Rails::VERSION::MAJOR == 3
  end

  require 'ubiquo_media/engine' if valid_rails?
end
