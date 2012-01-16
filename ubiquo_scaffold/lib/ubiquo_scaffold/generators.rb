# -*- encoding: utf-8 -*-

module UbiquoScaffold
  module Generators
    Dir.glob(File.join(File.dirname(__FILE__), '..', 'generators', '*.rb')).each do |source|
      require source
    end
  end
end
