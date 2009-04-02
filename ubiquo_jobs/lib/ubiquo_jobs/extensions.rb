module UbiquoJobs
  module Extensions
    autoload :Helper, 'ubiquo_jobs/extensions/helper'
  end
end

ActionController::Base.helper(UbiquoJobs::Extensions::Helper)
