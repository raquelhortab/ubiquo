# -*- encoding: utf-8 -*-

module Ubiquo
  class ScaffoldGenerator < UbiquoScaffold::Generators::Base

    [:model, :controller].each do |generator|
      hook_for generator, in: :ubiquo, type: :boolean, default: true
    end

  end
end
