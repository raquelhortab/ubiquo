class Ubiquo::SuperadminHomesController < UbiquoAreaController

  before_filter :superadmin_required
  
  def show
  end
  
end
