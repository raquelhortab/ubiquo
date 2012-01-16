# -*- encoding: utf-8 -*-

module UbiquoScaffold
  def self.valid_rails?
    defined?(Rails) && Rails::VERSION::MAJOR == 3
  end

  if valid_rails?
    require 'ubiquo_scaffold/generators'
    require 'ubiquo_scaffold/engine'
  end
end
