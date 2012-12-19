module UbiquoJobs
  module Extensions
    autoload :Helper, 'ubiquo_jobs/extensions/helper'
  end
end

:UbiquoController.helper! UbiquoJobs::Extensions::Helper
require 'ubiquo_jobs/extensions/array'