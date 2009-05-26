module UbiquoJobs
  module Extensions
    autoload :Helper, 'ubiquo_jobs/extensions/helper'
  end
end

Ubiquo::Extensions::UbiquoAreaController.append_helper(UbiquoJobs::Extensions::Helper)
